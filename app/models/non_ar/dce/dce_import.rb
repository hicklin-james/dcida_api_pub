require 'csv'
require 'zip'

class DceImport

  # for design, we need a hash like this:
  # {question_set: column_index, answer: column_index, properties: {prop_id: column_index, prop2_id: column_index, etc.}}

  DEFAULT_DESIGN_HEADER_STRINGS ||= ["question_set", "answer", "block"]

  def initialize(decision_aid, user_id)
    @decision_aid = decision_aid
    @user_id = user_id
  end

  def import_results
    begin
      ActiveRecord::Base.transaction do
        clear_previous_results_files
        if @decision_aid.dce_results_file.exists?
          csv_file = CSV.open Paperclip.io_adapters.for(@decision_aid.dce_results_file).path
          go_to_csv_row(csv_file, 0)
          # find row that has all option_ids
          option_ids = @decision_aid.options.where(has_sub_options: false).pluck(:id)
          r = create_column_option_map(option_ids, csv_file)
          comap = r[:comap]
          option_row_index = r[:option_row_index]
          go_to_csv_row(csv_file, option_row_index-1)
          generate_dce_result_matches(csv_file, comap)
        end
      end

      finish_upload_process(:dce_results_success)
      true
    
    rescue Exceptions::DceImportError => e
      handle_error(e, :dce_results_success)
    rescue ActiveRecord::RecordInvalid => e
      handle_error(e, :dce_results_success)
    rescue => e
      handle_error(e, :dce_results_success)
    end
  end

  def import_design
    begin
      ActiveRecord::Base.transaction do
        clear_previous_design_files
        if @decision_aid.dce_design_file.exists?
          csv_file = CSV.open Paperclip.io_adapters.for(@decision_aid.dce_design_file).path
          go_to_csv_row(csv_file, 0)
          # the first row needs to have 'question_set', 'answer', and each of the property titles in it, so find that row
          props = @decision_aid.properties
          prop_names = props.map {|p| p.title }
          header_match = DEFAULT_DESIGN_HEADER_STRINGS + prop_names
          h = csv_file.readline
          r = (header_match - h).compact # compact removes nils from array

          if validate_design_headers(r, prop_names)

            design_information_hash = Hash.new
            h.each_with_index do |line, index|
              design_information_hash[:question_set] = index if line == 'question_set'
              design_information_hash[:answer] = index if line == 'answer'
              design_information_hash[:block_number] = index if line == 'block'
            end
            # next, we need to create a mapping of property ids with column, id, and max_value attributes
            # to verify them
            prop_map = generate_property_map(csv_file, props, prop_names)
            design_information_hash[:properties] = prop_map.map {|p| [p[:id], p[:column_index]]}.to_h
            generate_dce_question_set_responses(csv_file, 3, design_information_hash, prop_map)
          end
          finish_upload_process(:dce_design_success)
          true
        end
      end

    rescue Exceptions::DceImportError => e
      handle_error(e, :dce_design_success)
    rescue ActiveRecord::RecordInvalid => e
      handle_error(e, :dce_design_success)
    rescue => e
      handle_error(e, :dce_design_success)
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
  # Results Functions

  def clear_previous_results_files
    DceResultsMatch.where(decision_aid_id: @decision_aid.id).destroy_all
  end

  def generate_dce_result_matches(csv_file, comap)
    first_line = csv_file.readline
    qrs_line = first_line.find_index("Question Response IDs") ? first_line : nil
    weights_line = qrs_line.nil? ? first_line : csv_file.readline
    weight_column = weights_line.find_index("weights")
    id_column = weights_line.find_index("ID")
    raise Exceptions::DceImportError, Exceptions::DceImportError::missing_label('weights') if weight_column.nil?
    raise Exceptions::DceImportError, Exceptions::DceImportError::missing_label('ID') if id_column.nil?
    csv_file.readline # go down another row
    csv_file.readlines.each_with_index do |l, i|
      question_sets = []
      ii = 0
      while ii < weight_column
        question_sets.push l[ii].to_i
        ii += 1
      end
      ii = id_column + 1
      option_ids = []
      qr_ids = nil
      id_hash = Hash.new
      while ii < l.length
        local_qrids = nil
        if qrs_line.nil?
          local_qrids = []
        elsif qrs_line[ii].blank?
          local_qrids = nil
        else
          local_qrids = qrs_line[ii].split(",").map{|ll| ll.split("~")}
        end
        if local_qrids
          if !id_hash.has_key?(local_qrids)
            id_hash[local_qrids] = Hash.new
          end
          id_hash[local_qrids][comap[ii]] = l[ii].to_f
        end
          #qr_ids = local_qrids
        ii += 1
      end
      #raise Exceptions::DceImportError, Exceptions::DceImportError::missing_option_label(i+1) if option_ids.empty?

      DceResultsMatch.create!(
        decision_aid_id: @decision_aid.id,
        response_combination: question_sets,
        option_match_hash: id_hash
      )

    end
  end

  def create_column_option_map(option_ids, csv_file)
    comap = nil
    option_row_index = nil
    csv_file.readlines.each_with_index do |l, i|
      if option_ids.all? {|oid| l.include?(oid.to_s)}
        comap = Hash.new
        id_column_passed = false
        l.each_with_index do |item, ii|
          if id_column_passed
            if item.to_i != 0
              comap[ii] = item.to_i
            end
          end
          if item == "ID"
            id_column_passed = true
          end
        end
        raise Exceptions::DceImportError, Exceptions::DceImportError::missing_label('ID') if !id_column_passed
        option_row_index = i
        break
      end
    end
    if comap.nil? then raise(Exceptions::DceImportError, Exceptions::DceImportError::MISSING_OPTION_ID_ROW) else return {comap: comap, option_row_index: option_row_index} end
  end

  # ---------------------------------- #
  # Design Functions


  def clear_previous_design_files
    DceQuestionSet.where(decision_aid_id: @decision_aid.id).destroy_all
    DceQuestionSetResponse.where(decision_aid_id: @decision_aid.id).destroy_all
  end

  def generate_property_map(csv_file, properties, prop_names)
    go_to_csv_row(csv_file, 0)
    line = csv_file.readline
    prop_map = []
    line.each_with_index do |l, i|
      if prop_names.include?(l)
        m = {column_index: i, name: l}
        prop_map.push m
      end
    end
    add_ids_and_max_values_to_property_map(prop_map, csv_file)
    validate_property_map(prop_map)
  end

  def add_ids_and_max_values_to_property_map(pm, csv_file)
    id_line = find_row_for_text("ID", csv_file)
    max_value_line = find_row_for_text("Maximum Value", csv_file)
    pm.each do |p|
      p[:id] = id_line[p[:column_index]]
      p[:max_value] = max_value_line[p[:column_index]]
    end
  end

  def find_row_for_text(str, csv_file)
    go_to_csv_row(csv_file, 0)
    match = nil
    csv_file.readlines.each do |l|
      if l.include?(str)
        match = l
        break
      end
    end
    raise Exceptions::DceImportError, Exceptions::DceImportError::missing_label(str) if match.nil?
    match
  end

  def validate_property_map(pm)
    pm.each do |p|
      if !Property.exists?(p[:id])
        raise Exceptions::DceImportError, Exceptions::DceImportError::INVALID_PROPERTY_ID
      else 
        prop = Property.find(p[:id])
        if prop.title != p[:name]
          raise Exceptions::DceImportError, Exceptions::DceImportError::PROPERTY_TITLE_ID_BAD_MATCH
        elsif prop.property_levels.count != p[:max_value].to_i
          raise Exceptions::DceImportError, Exceptions::DceImportError::MAX_PROPERTY_LEVEL_INCORRECT
        end
      end
    end
    pm
  end

  def validate_design_headers(r, prop_names)
    if r.empty?
      return true
    elsif (DEFAULT_DESIGN_HEADER_STRINGS.any? {|s| r.include?(s)})
      # we are missing a default header string, raise an exception
      raise Exceptions::DceImportError, Exceptions::DceImportError::DESIGN_HEADERS_MISSING
    elsif (prop_names.any? {|pn| r.include?(pn)})
      raise Exceptions::DceImportError, Exceptions::DceImportError::PROP_TITLE_MISSING
    else
      raise Exceptions::DceImportError, Exceptions::DceImportError::UNKNOWN_ERROR
    end
  end

  def is_order_row(r, design_information_hash)
    r[design_information_hash[:question_set]].downcase == 'order'
  end

  def generate_dce_question_set_responses(csv_file, start_row, design_information_hash, prop_map)
    go_to_csv_row(csv_file, start_row)

    #puts design_information_hash.inspect
    last_set = []
    created_responses = []
    # read each row into a DceQuestionSetResponse object and save it
    csv_file.readlines.each do |r|

      if is_order_row(r, design_information_hash)
        last_set.each do |s|
          n_h = design_information_hash[:properties].map {|k,v| [k, r[v]]}.to_h
          s.property_level_hash["orders"] = n_h
          s.save
        end
        last_set = []
      else
        # TODO -- RUN VALIDATIONS
        validate_design_row(r, design_information_hash, prop_map)

        response_value = (r[design_information_hash[:answer]] == "opt-out" ? -1 : r[design_information_hash[:answer]].to_i)
        is_opt_out = (response_value == -1)

        s = DceQuestionSetResponse.create!(
          question_set: r[design_information_hash[:question_set]].to_i,
          response_value: response_value,
          property_level_hash: design_information_hash[:properties].map {|k,v| [k, r[v]]}.to_h,
          decision_aid_id: @decision_aid.id,
          block_number: r[design_information_hash[:block_number]].to_i,
          is_opt_out: is_opt_out
        )
        last_set.push s
        created_responses.push s
      end

    end
    create_parent_entities(created_responses)
    validate_dce_question_set_response_set()
  end

  def create_parent_entities(responses)
    responses.group_by(&:question_set).each do |k, rs|
      nqs = DceQuestionSet.new(decision_aid_id: @decision_aid.id, dce_question_set_order: k, question_title: "Question Set #{k}")
      nqs.save
      rs.each do |r|
        r.dce_question_set_id = nqs.id
        r.save
      end
    end
  end

  def validate_dce_question_set_response_set
    grouped_response_sets = @decision_aid.dce_question_set_responses.group_by {|r| r.question_set}
    #puts grouped_response_sets.inspect
    raise Exceptions::DceImportError, Exceptions::DceImportError::UNEQUAL_ANSWERS_PER_SET if grouped_response_sets.map {|k,v| v.length }.uniq.length != 1
  end

  def validate_design_row(r, design_information_hash, prop_map)
    prop_map.each do |p|
      i = r[design_information_hash[:properties][p[:id]]].to_i
      if i > p[:max_value].to_i
          # puts "\n\n\nBAD!!!\n\n\n"
          # puts r.inspect
          # puts design_information_hash.inspect
          # puts i
          # puts p[:max_value]
          # puts p.inspect
        raise Exceptions::DceImportError, Exceptions::DceImportError::PROPERTY_LEVEL_OUT_OF_RANGE
      end
    end
  end

  def go_to_csv_row(csv_file, n)
    # go to beginning of CSV file
    csv_file.rewind
    # read n rows
    n.times { csv_file.readline }
  end
end