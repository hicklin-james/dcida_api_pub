# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/whenever.log"

every 1.day, :at => '2:30 am' do
  runner "DecisionAidUserSession.remove_old_sessions"
end

every 1.day, :at => '2:30 am' do
  runner 'DownloadItem.remove_old_download_items'
end

every 2.minutes do
  runner "DataTargetExportWorker.clear_stale_jobs"
end

# every 1.day, :at => '2:30 am' do
#   # clear out tmp files
#   command "rm -rf #{path}/tmp/*.zip && rm -rf #{path}/tmp/download_tmp"
# end