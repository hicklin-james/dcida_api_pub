require 'csv'
require 'zip'

class ExportBw

  TMP_PATH = "#{Rails.root}/tmp/download_tmp"

  def initialize(decision_aid, download_item, user_id, num_questions, num_attributes_per_question, num_blocks)
    @user_id = user_id
    @decision_aid = decision_aid
    @download_item = download_item
    @num_questions = num_questions.to_i
    @num_blocks = num_blocks.to_i
    @num_attributes_per_question = num_attributes_per_question.to_i
    @time_started = Time.now.strftime("%Y%m%d%H%M%S")
    rel_folder = "system/download_items/#{@time_started}/#{decision_aid.id}"

    @zip_folder = Rails.env.test? ? "#{Rails.root}/rspec_tmp/#{rel_folder}" : "#{Rails.root}/public/#{rel_folder}"
    FileUtils::mkdir_p @zip_folder
    file_name_suffix = "Best-Worst Template Files.zip"
    @zip_path = "#{@zip_folder}/#{decision_aid.title} #{file_name_suffix}"
    @rel_path = "#{rel_folder}/#{decision_aid.title} #{file_name_suffix}"
  end

  def create_bw_template_files
    begin
      basic_validation

      levels = @decision_aid.property_levels
        .joins(:property)
        .select("property_levels.*, properties.title as property_title, properties.property_order as property_order")
        .order("property_order ASC, level_id ASC")

      file = CSV.generate do |csv|
        generate_headers(levels, csv)
        generate_content(csv)
      end

      add_csv_to_disk("Best-Worst Design", file)

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
      FileUtils::rm_rf "#{TMP_PATH}/#{@time_started}"
    end
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

  def basic_validation
    raise Exceptions::BwExportError, Exceptions::BwExportError::NO_PROPERTIES if @decision_aid.properties_count == 0
    props_with_no_levels = @decision_aid.properties.ordered.where(:property_levels_count => 0).pluck(:title)
    raise Exceptions::BwExportError, Exceptions::BwExportError::props_missing_levels(props_with_no_levels) if props_with_no_levels.length > 0
    raise Exceptions::BwExportError, Exceptions::BwExportError::NO_OPTIONS if ((@decision_aid.options_count == 0) and (@decision_aid.decision_aid_type != "best_worst_no_results"))
    raise Exceptions::BwExportError, Exceptions::BwExportError::NUM_QUESTIONS_ZERO if @num_questions <= 0
    raise Exceptions::BwExportError, Exceptions::BwExportError::NUM_ATTRIBUTES_ZERO if @num_attributes_per_question <= 0
  end

  def add_csv_to_disk(file_name, file)
    FileUtils::mkdir_p "#{TMP_PATH}/#{@time_started}"
    path = File.join("#{TMP_PATH}/#{@time_started}", "#{file_name}.csv")
    File.open(path, "wb") { |f| f.write(file)}
  end

  def generate_headers(levels, csv)
    top_level_headers = ["", "", "Attributes per question", "Attribute levels"]
    sub_headers = ["Level ID", "", @num_attributes_per_question] + levels.map(&:id)
    sub_sub_headers = ["Question Set", "Block", ""] + levels.map{|l| "#{l.property_title} - Level #{l.level_id}"}

    [top_level_headers, sub_headers, sub_sub_headers].each do |header_row|
      csv << header_row
    end
  end

  def generate_content(csv)
    for i in 0..@num_questions-1
      for j in 0..@num_blocks-1
        csv << [i + 1, j + 1]
      end
    end
  end
end