require 'unirest'

class RedcapService

  def initialize(decision_aid)
    @decision_aid = decision_aid
    @base_params = {
      token: decision_aid.redcap_token,
      format: "json"
    }
  end

  def test_connection
    begin
      r = make_request({content: "version"})
      if r.body.to_i != 0
        {body: r.body}
      else
        {error: r.body}
      end
    rescue StandardError => e
      {error: e}
    end
  end 

  def test_question(redcap_question_variable)
    begin
      r = make_request({content: "metadata", fields: [redcap_question_variable]})
      response_data = r.body
      if response_data and response_data.length == 1
        datum = response_data.first
        response_variables = datum["select_choices_or_calculations"]
        {
          body: {redcap_question_response_variables: response_variables.split("|").map {|choice| choice.split(",").first.strip}}
        }
      else
        {error: "No redcap field with that name found"}
      end
    rescue StandardError => e
      {error: e}
    end
  end

  def get_valid_redcap_fields
    begin
      params = {content: "metadata"}
      r = make_request(params)
      response_data = r.body
      return [] if !response_data or response_data.length == 0
      return response_data.map { |rd| {field_name: rd["field_name"], field_type: rd["field_type"]} }.reject{ |h| h[:field_name].nil? }
    rescue StandardError => e
      Rails.error "Error getting valid redcap fields with message <#{e.message}>"
    end
    []
  end

  def get_valid_redcap_response_fields(question_variable)
    begin
      params = {content: "metadata", fields: [question_variable]}
      r = make_request(params)
      response_data = r.body
      return [] if !response_data or response_data.length != 1
      field = response_data.first
      if field["field_type"] == 'yesno'
        # yes/no questions treated differently to radio in REDCap
        return ["1", "0"]
      elsif field["select_choices_or_calculations"]
        return field["select_choices_or_calculations"].split("|").map{ |choice| choice.split(",").first.strip }
      end
    rescue StandardError => e
      Rails.logger.error "Error getting valid redcap response fields with message <#{e.message}>"
    end
    []
  end

  def get_filter_field
    urid = @decision_aid.unique_redcap_record_identifier
    if urid.blank? then "record_id" else urid end
  end

  def generate_user_filter(primary_param_id)
    {filterLogic: "[#{get_filter_field()}] = '#{primary_param_id}'"}
  end

  def export(fields, decision_aid_user)
    #data_targets = DataExportField.where(id: field_ids).includes(:exporter)

    primary_param_id = decision_aid_user.pid
    return if primary_param_id.nil? or fields.empty?

    user_filter = generate_user_filter(primary_param_id)
    params = {content: "record"}.merge(user_filter)
    valid_fields = get_valid_redcap_fields()
    Rails.logger.debug "Valid fields: <#{valid_fields}>"

    return if valid_fields.empty?
    
    # first field in valid_fields is always the primary ID for REDCap, so we should allow it always
    params[:fields] = valid_fields.map{|f| f[:field_name]} & fields.map(&:redcap_field_name).unshift(valid_fields.first[:field_name])

    r = make_request(params)
    response_data = r.body
    if response_data and response_data.length >= 1
      record = response_data.first

      file_requests = []

      param_data = Hash.new

      fields.each do |field|
        redcap_variable_name = field.redcap_field_name
        rc_field = valid_fields.find{|fo| fo[:field_name] == redcap_variable_name}

        if rc_field
          data_source = field.exporter
          rc_data_type = rc_field[:field_type]

          switcher = nil
          if data_source == "Other"
            switcher = "Other"
          else
            switcher = data_source.class.to_s
          end 

          case switcher
          when "Question"
            daur = data_source.decision_aid_user_responses.find_by(question_id: field.exporter_id, decision_aid_user_id: decision_aid_user.id)
            if daur
              daur = daur.becomes(RedcapDecisionAidUserResponse)
              value = daur.get_relevant_value_for_target(data_source, field.redcap_response_mapping).to_s
              if data_source.question_response_type == 'radio' or data_source.question_response_type == 'yes_no'
                valid_response_values = get_valid_redcap_response_fields(redcap_variable_name)
                fv = nil
                if !valid_response_values.blank?
                  Rails.logger.debug "Checking redcap_response_values <#{valid_response_values.inspect}> for value <#{value.to_s}>"
                  fv = valid_response_values.find { |vl| vl.to_s == value.to_s }
                end
                value = if fv then value else nil end
              end

              if record.has_key?(redcap_variable_name)
                record[redcap_variable_name] = value
              end
            end
          when "Property"
            daup = data_source.decision_aid_user_properties.find_by(property_id: field.exporter_id, decision_aid_user_id: decision_aid_user.id)
            if daup
              daup = daup.becomes(RedcapDecisionAidUserProperty)
              value = daup.get_relevant_value_for_target(@decision_aid.decision_aid_type)
              if record.has_key?(redcap_variable_name)
                record[redcap_variable_name] = value
              end
            end
          when "SummaryPage"
            dausp = data_source.decision_aid_user_summary_pages.find_by(summary_page_id: field.exporter_id, decision_aid_user_id: decision_aid_user.id)
            if dausp
              if rc_data_type == "file"
                begin
                  f = File.open(dausp.summary_page_file.path, 'rb')
                  record_request = {content: "file", action: "import", record: record["record_id"], field: redcap_variable_name, file: f}
                  file_requests.push record_request
                rescue 
                  Rails.logger.error "File at path #{dausp.summary_page_file.path} not found!!! Continuing with other export fields..."
                end
              else
                value = dausp.summary_page_file.url
                if record.has_key?(redcap_variable_name)
                  record[redcap_variable_name] = value
                end
              end
            end
          when "Other"
            dau = decision_aid_user.becomes(RedcapDecisionAidUser)
            value = dau.get_relevant_value_for_target(field.data_accessor)
            if record.has_key?(redcap_variable_name)
              record[redcap_variable_name] = value
            end
          else
            Rails.logger.error "Data source with class <#{data_source.class.to_s}> not supported for data export."
          end
        end
      end

      delete_file_fields(record, valid_fields)
      
      do_final_requests(record, file_requests)
    end
  end

  def do_final_requests(record, file_requests)
    begin
      r = make_request({content: "record", overwriteBehavior: "overwrite", data: [record].to_json})
      file_requests.each do |r_params|
        make_request(r_params)
      end
    rescue Exception => e
      # reraise any exception
      raise
    ensure
      # ensure all files are closed
      file_requests.each do |r_params|
        if r_params[:file]
          Rails.logger.debug "Closing file"
          r_params[:file].close
        end
      end
    end
  end

  def delete_file_fields(record, valid_fields)
    valid_fields.each do |field|
      if field[:field_type] == "file"
        record.delete(field[:field_name])
      end
    end
  end

  def import(questions, decision_aid_user)
    primary_param_id = decision_aid_user.pid
    return if primary_param_id.nil? or questions.empty?

    begin
      params = {content: "record"}.merge(generate_user_filter(primary_param_id))

      r = make_request(params)
      inserted_question_ids = []
      insert_values = []
      response_data = r.body

      if response_data and response_data.length == 1
        response_datum = response_data.first
        questions.each do |q|
          qr_hash = q.question_responses.index_by(&:redcap_response_value).with_indifferent_access
          if response_datum[q.redcap_field_name]
            if q.question_response_type == "number" and !response_datum[q.redcap_field_name].blank?
              insert_values.push "(#{decision_aid_user.id},#{q.id},NULL,#{response_datum[q.redcap_field_name]},NULL,'#{Time.now.to_s}','#{Time.now.to_s}')"
              inserted_question_ids.push q.id
            elsif q.question_response_type == "radio" and qr = qr_hash[response_datum[q.redcap_field_name]]
              insert_values.push "(#{decision_aid_user.id},#{q.id},NULL,NULL,#{qr.id},'#{Time.now.to_s}','#{Time.now.to_s}')"
              inserted_question_ids.push q.id
            elsif q.question_response_type == "text"
              insert_values.push "(#{decision_aid_user.id},#{q.id},'#{response_datum[q.redcap_field_name]}',NULL,NULL,'#{Time.now.to_s}','#{Time.now.to_s}')"
              inserted_question_ids.push q.id
            end
          end
        end
      end

      if insert_values.length > 0
        ActiveRecord::Base.connection.execute("INSERT INTO decision_aid_user_responses (decision_aid_user_id, question_id, response_value, number_response_value, question_response_id, created_at, updated_at) VALUES #{insert_values.join(',')}")
      end
      inserted_question_ids
    rescue StandardError => e
      Rails.logger.error "Importing from REDCap failed with error <#{e.message}>"
      []
    end
  end

  private

  def make_request(additional_params)
    params_to_send = @base_params.merge(additional_params)
    Unirest.timeout(15)
    Rails.logger.debug "Sending data: <#{params_to_send.inspect}> to REDCap"
    res = Unirest.post(@decision_aid.redcap_url, 
                       headers: {"Accept" => "application/json"},
                       parameters: params_to_send)
    if res.code == 200
      Rails.logger.debug "Request succeeded with response body <#{res.body.to_s}>"
      res
    else
      Rails.logger.error "Request failed with response code <#{res.code.to_s}> and body <#{res.body.to_s}>"
      raise Exceptions::RedcapRequestFailed, res.body.inspect
    end
  end

end