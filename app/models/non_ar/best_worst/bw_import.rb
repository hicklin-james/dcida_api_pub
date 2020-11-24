require 'csv'
require 'zip'

class BwImport

  def initialize(decision_aid, user_id)
    @decision_aid = decision_aid
    @user_id = user_id
  end

  def import_design
    begin
      ActiveRecord::Base.transaction do
        clear_previous_design_files
        if @decision_aid.bw_design_file.exists?
          csv_file = CSV.open Paperclip.io_adapters.for(@decision_aid.bw_design_file).path
          go_to_csv_row(csv_file, 0)
          attributes_per_question_column = find_attributes_per_question_column(csv_file)
          info_hash = generate_info_hash(csv_file, attributes_per_question_column)
          csv_file.readline
          generate_bw_question_set_responses(csv_file, info_hash)
        end
      end

      finish_upload_process(:bw_design_success)
      true

    rescue Exceptions::BwImportError => e
      handle_error(e, :bw_design_success)
    rescue ActiveRecord::RecordInvalid => e
      handle_error(e, :bw_design_success)
    rescue => e
      handle_error(e, :bw_design_success)
    end
  end

  private

  def finish_upload_process(success_attribute)
    @decision_aid.update_attribute(success_attribute, true)
    private_channel = 'complete_' + @user_id.to_s

    s = DecisionAidSerializer.new(@decision_aid)
    adapter = ActiveModelSerializers::Adapter.create(s)
    WebsocketRails[:uploadItems].trigger private_channel, adapter.as_json
  end

  def handle_error(exception, success_attribute)
    @decision_aid.update_attribute(success_attribute, false)
    private_channel = 'error_' + @user_id.to_s

    s = DecisionAidSerializer.new(@decision_aid)
    adapter = ActiveModelSerializers::Adapter.create(s)

    WebsocketRails[:uploadItems].trigger private_channel, {message: exception.message, decision_aid: adapter.as_json[:decision_aid]}
    exception
  end

  # ---------------------------------- #
  # Design Functions

  def clear_previous_design_files
    BwQuestionSetResponse.where(decision_aid_id: @decision_aid.id).destroy_all
  end

  def generate_bw_question_set_responses(csv_file, info_hash)
    csv_file.readlines.each_with_index do |line, i|
      question_set = line[0].to_i
      block = line[1].to_i
      #property_level_ids = line[2..line.length].each_with_index.select{|v| !v.blank? }.select{|v| v.to_i == 1}.map{|v,i| info_hash[:property_level_columns][]}
      index = 2
      property_level_ids = []
      while index < line.length
        selected = line[index].to_i
        if selected == 1
          id = info_hash[:property_level_columns][index]
          property_level_ids.push info_hash[:property_level_columns][index]
        end
        index += 1
      end
      if property_level_ids.length == info_hash[:attributes_per_question]
        BwQuestionSetResponse.create(
          question_set: question_set,
          block_number: block,
          property_level_ids: property_level_ids,
          decision_aid_id: @decision_aid.id
        )
      else
        raise Exceptions::BwImportError, Exceptions::BwImportError::wrong_number_attributes(i+1, info_hash[:attributes_per_question])
      end
    end
  end

  def generate_info_hash(csv_file, attributes_per_question_column)
    line = csv_file.readline
    raise Exceptions::BwImportError, Exceptions::BwImportError::NO_LEVEL_ID_LABEL if !line.include?("Level ID")
    info_hash = Hash.new
    info_hash[:attributes_per_question] = line[attributes_per_question_column].to_i
    info_hash[:property_level_columns] = Hash.new
    counter = attributes_per_question_column + 1
    while counter < line.length 
      id = line[counter]
      if !id.blank?
        info_hash[:property_level_columns][counter] = id
      end
      counter += 1
    end
    info_hash
  end

  def find_attributes_per_question_column(csv_file)
    line = csv_file.readline
    col = line.find_index("Attributes per question")
    raise Exceptions::BwImportError, Exceptions::BwImportError::NO_ATTRIBUTES_PER_QUESTION_HEADER if col.nil?
    col
  end

  def go_to_csv_row(csv_file, n)
    # go to beginning of CSV file
    csv_file.rewind
    # read n rows
    n.times { csv_file.readline }
  end
end