require 'sidekiq/api'

class DataTargetExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'data_export'

  def perform(target_ids, decision_aid_user_id)
    Rails.logger.debug "Start, target_ids <#{target_ids.to_s}>, decision_aid_user_id <#{decision_aid_user_id}>"
    target_ids = target_ids.uniq
    object_target_groups = DataExportField.grouped_by_data_target(target_ids)

    dau = DecisionAidUser.find_by(id: decision_aid_user_id)
    
    # if decision aid user is deleted, we might get stuck trying over and over again
    if dau and !object_target_groups.empty?
      da = dau.decision_aid
      
      object_target_groups.each do |k, o_arr|
        if o_arr.length > 0
          overlap = get_overlap(o_arr)

          if overlap.length > 0
            handle_overlap(o_arr, overlap, decision_aid_user_id)
            Rails.logger.debug "Finish."
            return
          end

          # no items currently being worked on, so proceed normally. In the case of a race condition the INSERT below
          # will throw an error so we can still recover
          begin
            insert_into_currently_exporting(o_arr, decision_aid_user_id)
            case k
            when "redcap"
              rs = RedcapService.new(da)
              rs.export(o_arr, dau)
            else
              Rails.logger.warn "Remote data target with type <#{k}> not supported"
            end
          rescue Exception => e
            Rails.logger.error "Caught exception with type <#{e.class}> and message <#{e.message}>, proceed with normal exception handling after cleanup"
            raise
          ensure
            cleanup_currently_editing
          end
        end
      end
    end
    Rails.logger.debug "Finish."
  end

  def insert_into_currently_exporting(targets, decision_aid_user_id)
    currently_editing_query = "INSERT INTO currently_exporting_rdts (data_export_field_id, decision_aid_user_id, thread_id) VALUES "
    values = targets.map{|o| '(' + o.id.to_s + ',' + decision_aid_user_id.to_s + ',\'' + self.jid + '\')'}.join(",")
    currently_editing_query += values

    ActiveRecord::Base.connection.execute(currently_editing_query)
    Rails.logger.debug("Inserted using query <#{currently_editing_query}>")
  end

  def get_overlap(targets)
    sql = "SELECT data_export_field_id FROM currently_exporting_rdts WHERE data_export_field_id IN (#{targets.map(&:id).join(',')})"
          
    ActiveRecord::Base.connection
      .execute(sql)
      .values
      .flatten
      .map{|v| v.to_i}
  end

  def handle_overlap(orignal_arr, overlapped_target_ids, decision_aid_user_id)
    Rails.logger.debug "Found some overlap <#{overlapped_target_ids.to_s}> between target_ids and already being worked on. Reschedule these for later."
    filtered_object_ids = orignal_arr.reject{ |o| overlapped_target_ids.include?(o.id) }

    queued_jobs = Sidekiq::ScheduledSet.new
    same_job_already_queued = queued_jobs.find{ |job| job.queue == 'data_export' and 
                                                      job.args[0] == overlapped_target_ids and 
                                                      job.args[1] == decision_aid_user_id }
    
    # split into 2 new jobs, one for the overlapped question_ids (if not already queued) and one for the 
    # question_ids that aren't being worked on
    if !same_job_already_queued
      Rails.logger.debug "Queueing overlapped fields for new job with target_ids <#{overlapped_target_ids}>"
      # schedule in future since currently active jobs may take some time
      DataTargetExportWorker.perform_in(10.seconds, overlapped_target_ids, decision_aid_user_id)
    else
      Rails.logger.debug "Job with target_ids <#{overlapped_target_ids}> and decision_aid_user_id <#{decision_aid_user_id}> already queued. Nothing more to do."
    end

    if filtered_object_ids.length > 0
      # no other thread is working on these, so schedule immediately
      unoverlapped_target_ids = filtered_object_ids.map(&:id)
      Rails.logger.debug "Starting new job for non-overlapped target_ids <#{unoverlapped_target_ids.to_s}> immediately."
      DataTargetExportWorker.perform_async(unoverlapped_target_ids, decision_aid_user_id)
    end
  end

  def cleanup_currently_editing
    Rails.logger.debug "Cleaning up currently_editing values from job <#{self.jid}>"
    currently_editing_clear_query = "DELETE FROM currently_exporting_rdts WHERE thread_id = '#{self.jid}'"
    ActiveRecord::Base.connection.execute(currently_editing_clear_query)
    Rails.logger.debug "Called query: <#{currently_editing_clear_query}>"
  end

  # routine called by cron on some interval
  def self.clear_stale_jobs
    data_export_jobs = Sidekiq::Workers.new
      .select{ |pid, tid, work| work["queue"] == "data_export" && work["payload"] && work["payload"]["jid"] }
      .map{ |pid, tid, work| "'" + work["payload"]["jid"] + "'" }

    sql = nil
    
    if data_export_jobs.length > 0
      sql = "DELETE FROM currently_exporting_rdts WHERE thread_id NOT IN (#{data_export_jobs.join(',')})"
    else
      sql = "DELETE FROM currently_exporting_rdts"
    end

    # since this is run from whenever, silence the logger so that we don't clutter up the development log
    ActiveRecord::Base.logger.silence do
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end