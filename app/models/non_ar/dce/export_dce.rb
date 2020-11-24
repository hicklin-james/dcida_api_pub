require 'csv'
require 'zip'

class ExportDce

  TMP_PATH = "#{Rails.root}/tmp/download_tmp"

  def initialize(decision_aid, download_item, user_id, num_questions, num_answers, num_blocks, include_opt_out)
    @user_id = user_id
    @decision_aid = decision_aid
    @download_item = download_item
    @num_questions = num_questions.to_i
    @include_opt_out = include_opt_out
    @num_answers = num_answers.to_i
    @num_blocks = num_blocks.to_i
    @time_started = Time.now.strftime("%Y%m%d%H%M%S")
    rel_folder = "system/download_items/#{@time_started}/#{decision_aid.id}"

    @zip_folder = Rails.env.test? ? "#{Rails.root}/rspec_tmp/#{rel_folder}" : "#{Rails.root}/public/#{rel_folder}"
    FileUtils::mkdir_p @zip_folder
    @zip_path = "#{@zip_folder}/#{decision_aid.title} DCE Template Files.zip"
    @rel_path = "#{rel_folder}/#{decision_aid.title} DCE Template Files.zip"
  end

  def create_dce_template_files

    begin
      basic_dce_validation
      design_csv = setup_design_dce
      results_csv = setup_results_dce

      Zip::File.open(@zip_path, Zip::File::CREATE) do |zipfile|
        Dir.foreach("#{TMP_PATH}/#{@time_started}") do |item|
          next if item == "." or item == ".." or item == ".DS_Store"
          #puts item.inspect
          zipfile.add(item, "#{TMP_PATH}/#{@time_started}/#{item}")
        end
      end
      File.chmod(0644, @zip_path)
      finish_download_process
    rescue => e
      handle_error(e)
    ensure
      if TMP_PATH and @time_started and TMP_PATH != "/" and @time_started != "/" and File.exist?("#{TMP_PATH}/#{@time_started}")
        FileUtils::rm_rf "#{TMP_PATH}/#{@time_started}"
      end
    end

    # @download_item.update_attributes(file_location: @rel_path, processed: true)

    # # broadcast to client through websocket
    # private_channel = 'complete_' + @user_id.to_s
    # WebsocketRails[:downloadItems].trigger private_channel, @download_item

    # @download_item
  end

  private

  def finish_download_process
    @download_item.update_attributes(file_location: @rel_path, processed: true)

    private_channel = 'complete_' + @user_id.to_s

    s = DecisionAidSerializer.new(@decision_aid)
    adapter = ActiveModelSerializers::Adapter.create(s)
    WebsocketRails[:downloadItems].trigger private_channel, {download_item: @download_item, decision_aid: adapter.as_json}
    {success: true, download_item: @download_item}
  end

  def handle_error(exception)
    private_channel = 'error_' + @user_id.to_s

    s = DecisionAidSerializer.new(@decision_aid)
    adapter = ActiveModelSerializers::Adapter.create(s)

    WebsocketRails[:downloadItems].trigger private_channel, {message: exception.message, decision_aid: adapter.as_json[:decision_aid]}
    {success: false, exception: exception, download_item: @download_item}
  end

  def basic_dce_validation
    raise Exceptions::DceExportError, Exceptions::DceExportError::NO_PROPERTIES if @decision_aid.properties_count == 0
    props_with_no_levels = @decision_aid.properties.ordered.where(:property_levels_count => 0).pluck(:title)
    raise Exceptions::DceExportError, Exceptions::DceExportError::props_missing_levels(props_with_no_levels) if props_with_no_levels.length > 0
    #raise Exceptions::DceExportError, Exceptions::DceExportError::NO_OPTIONS if @decision_aid.options_count == 0
    raise Exceptions::DceExportError, Exceptions::DceExportError::NUM_QUESTIONS_ZERO if @num_questions <= 0 || @num_questions > 20
    raise Exceptions::DceExportError, Exceptions::DceExportError::NUM_RESPONSES_LESS_THAN_TWO if @num_answers <= 1 || @num_answers > 3
  end

  def add_csv_to_disk(file_name, file)
    FileUtils::mkdir_p "#{TMP_PATH}/#{@time_started}"
    path = File.join("#{TMP_PATH}/#{@time_started}", "#{file_name}.csv")
    File.open(path, "wb") { |f| f.write(file)}
  end

  # DCE Design export functions #
  # -------------------------------------------- #

  def setup_design_dce
    file = CSV.generate do |csv|
      dce_design_headers(csv)
      dce_design_content(csv)
    end
    add_csv_to_disk("dce_design", file)
  end

  def dce_design_headers(csv)
    generic_headers = ["question_set", "answer", "block", ""]
    l = generic_headers.length
    r = property_headers
    #prop_headers = property_headers
    prop_headers = r.length > 0 ? r : [[],[], []]
    csv << generic_headers.concat(prop_headers.first)
    raise Exceptions::DceExportError, Exceptions::DceExportError::GENERIC_HEADER_LENGTH_ZERO if l == 0
    csv << Array.new(l-1, " ").push("ID").concat(prop_headers.second)
    csv << Array.new(l-1, " ").push("Maximum Value").concat(prop_headers.third)
    #props = @decision_aid.properties
    #headers += Array.new(props.length){|i| "att_#{(i+1).to_s}_#{props[i].title}"}
    #headers
  end

  def property_headers
    props = @decision_aid.properties.ordered
    prop_headers = props.pluck(:title, :id, :property_levels_count)
    prop_headers.transpose
  end

  def dce_design_content(csv)
    prop_count = @decision_aid.properties.length
    for p in 1..@num_blocks
      for i in 1..@num_questions
        for s in 1..@num_answers
          row = [i.to_s, s.to_s, p.to_s]
          csv << row
          # for t in 0..prop_count-1
          #   row << " "
          # end
          # csv << row
        end
        if @include_opt_out
          csv << [i.to_s, "opt-out", p.to_s]
        end
        csv << ['Order', '-->', p.to_s]
      end
    end
  end

  # DCE Results export functions #
  # -------------------------------------------- #

  def setup_results_dce
    file = CSV.generate do |csv|
      dce_results_headers(csv)
      dce_results_content(csv)
    end
    add_csv_to_disk("dce_results", file)
  end

  def dce_results_headers(csv)

    # the goal here is to get all of the permutations of the different options
    # and place them side by side, so that each group adds up to 100%. Furthermore,
    # we need the question responses that correspond to that option combination
    option_headers = generate_question_response_option_headers(csv)

    sub_headers = Array.new(@num_questions){|i| "question_set_#{(i+1).to_s}"}
    props = @decision_aid.properties.ordered
    raise Exceptions::DceExportError, Exceptions::DceExportError::NO_PROPERTIES if props.length == 0
    sub_headers += Array.new(props.length){|i| "att_#{props[i].id.to_s}_#{props[i].title}"}
    empty_length = sub_headers.length
    option_headers.each_with_index do |oh, i|
      if i < option_headers.length - 2
        h = Array.new(empty_length, " ") + oh
        csv << h
      elsif i == option_headers.length - 2
        h = Array.new(@num_questions, " ")
        h << "weights"
        h = h.concat Array.new(props.length - 1, " ")
        h = h.concat oh 
        csv << h
      end
    end
    csv << (sub_headers + (option_headers.length > 0 ? option_headers.last : []))
  end

  def generate_question_response_option_headers(csv)
    qr_id_arrays = get_question_response_id_arrays
    response_sets = get_response_permutations(qr_id_arrays)
    set_hash = build_option_set_hash(response_sets)
    final_hash = remove_complete_response_sets(set_hash, qr_id_arrays)
    untransposed_array = generate_untransposed_array(final_hash)
    add_empty_space_to_untransposed_array(untransposed_array)
    untransposed_array.transpose.reverse
  end

  # find the untransposed array with the biggest length, and add blank elements onto the
  # end of each array
  def add_empty_space_to_untransposed_array(untransposed_array)
    if !untransposed_array.blank?
      biggest_length = untransposed_array.max_by(&:length).length
      untransposed_array.each do |a|
        diff = biggest_length - a.length
        if diff > 0
          empty_array = Array.new(diff, " ")
          a.concat empty_array
        end
      end
    end
  end

  def join_question_responses(qr_hashes, questions_hash)
    values = []
    last_question_id = nil
    qr_hashes.each_with_index do |qr_hash, i|
      if qr_hash[:question_id] == last_question_id
        values[values.length-1][:v] += "/#{qr_hash[:v]}"
        values[values.length-1][:is].push qr_hash[:id]
      else
        q = questions_hash[qr_hash[:question_id]]
        values.push({v: qr_hash[:v], t: q.question_text, is: [qr_hash[:id]], qid: q.id})
      end
      last_question_id = qr_hash[:question_id]
    end
    values
  end

  def generate_untransposed_array(final_hash)
    untransposed_array = []
    option_name_hash = Hash[*@decision_aid.options.pluck(:id, :title).flatten]
    questions_hash = @decision_aid.demographic_questions
      .where("questions.question_response_type = ? OR questions.question_response_type = ?", Question.question_response_types[:radio], Question.question_response_types[:yes_no])
      .index_by(&:id)
    final_hash.each_with_index do |(k,v),index|
      values = join_question_responses(v, questions_hash)
      if index == 0
        untransposed_array.push []
        row_labels = ["Option name", "ID"]
        if values.length > 0
          row_labels.concat(["Question Response IDs", " "])
          row_labels.concat(values.map{|vv| vv[:t]})
        end
        untransposed_array.push row_labels
      else
        untransposed_array.push []
      end
      k.each do |o_id|
        inner_array = []
        inner_array.push option_name_hash[o_id]
        inner_array.push o_id
        if values.length > 0
          inner_array.push values.group_by{|vv| vv[:qid]}.map{|kk,vv| vv.map{|kkk,vvv| kkk[:is]}.join("~")}.join(",")
          inner_array.push(" ")
          inner_array.concat values.map{|vv| vv[:v]}
        end
        untransposed_array.push inner_array
      end
    end
    untransposed_array
  end

  # removes items that include all responses, as they are not needed on the
  # csv sheet
  def remove_complete_response_sets(set_hash, qr_id_arrays)
    sortArray = @decision_aid.question_responses.reorder(question_id: :asc).map{|qr| {v: qr.question_response_value, id: qr.id, question_id: qr.question_id}}
    final_hash = Hash.new
    # for each question, if all question responses exist in the set hash,
    # remove them for clarity
    qrid_arrays = 
    set_hash.each do |k, v|
      s = v
      qr_id_arrays.each do |qrsids|
        #qrsids = q.question_responses.pluck(:id)
        if qrsids.all? {|id| s.map{|ss| ss[:id]}.include?(id)}
          s = s.reject {|a| qrsids.include?(a[:id])}
        end
      end
      final_hash[k] = s.sort_by{|qrv| sortArray.index(qrv)}
    end
    final_hash
  end

  def build_option_set_hash(response_sets)
    set_hash = Hash.new

    response_sets.each do |os|
      options = @decision_aid.relevant_options(nil, os)
      key = options.map(&:id).sort
      response_hashes = @decision_aid.question_responses.where(id: os).reorder(question_id: :asc).map{|qr| {v: qr.question_response_value, id: qr.id, question_id: qr.question_id}}
      if set_hash.has_key?(key)
        set_hash[key] = set_hash[key].concat(response_hashes).uniq
      else
        set_hash[key] = response_hashes
      end
    end
    set_hash
  end

  def get_question_response_id_arrays
    response_arrays = @decision_aid.demographic_questions
      .where("questions.question_response_type = ? OR questions.question_response_type = ?", Question.question_response_types[:radio], Question.question_response_types[:yes_no])
      .joins(:question_responses)
      .select("questions.id, question_responses.id as qrid")
      .group_by(&:id)
      .map{|k,v| v.map(&:qrid)}
    response_arrays
  end

  def get_response_permutations(qr_id_arrays)
    question_response_id_array = @decision_aid.options
      .where(:has_sub_options => false)
      .pluck(:question_response_array)
    
    intersected_question_response_ids = question_response_id_array.inject(:&)
    
    # only return question_responses that filter options, UNLESS there are none
    # ie. the question_response_id_arrays are all the same
    if question_response_id_array.uniq.length > 1
      response_arrays = qr_id_arrays
        .select {|ids| !(ids - intersected_question_response_ids).empty? }
    else
      response_arrays = [qr_id_arrays.first]
    end
    response_arrays.length > 0 && !response_arrays.first.nil? ? response_arrays.first.product(*response_arrays[1..-1]) : []
  end

  def dce_results_content(csv)
    choice_array = [*1..@num_answers]
    # this is incredibly slow - how can we improve it?
    perms = choice_array.repeated_permutation(@num_questions)
    perms.each do |perm|
      csv << perm
    end
  end

end