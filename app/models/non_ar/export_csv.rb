require 'csv'
require 'zip'

class ExportCsv

  DECISION_AID_MODELS = {
    option: {class_name: "Option", children: {
      media_file: {class_name: "MediaFile", has_attached_images: true, attachment_name: "image"}
    }}, 
    property: {class_name: "Property"}, 
    option_property: {class_name: "OptionProperty"}, 
    question: {class_name: "Question"}, 
    question_response: {class_name: "QuestionResponse"}, 
    icon: {class_name: "Icon", has_attached_images: true, attachment_name: "image"}  
  }.freeze

  def initialize(decision_aid, download_item, user_id)
    @decision_aid = decision_aid
    @download_item = download_item
    @user_id = user_id
    @zip_path = "tmp/#{SecureRandom.uuid}.zip"
  end

  def export
    # 1: copy the decision aid attributes to csv
    build_csv("decision_aid_csv", DecisionAid, [{header: 'icon_image_name', func: :icon_image_name}], [@decision_aid])

    DECISION_AID_MODELS.each do |k,v|
      klass = Object.const_get v[:class_name]
      items = klass.where(decision_aid_id: @decision_aid.id)
      build_csv("#{v[:class_name].underscore}_csv", klass, {}, items)
      if v[:has_attached_images]
        copy_attached_images(items, v)
      end
      if v[:children]
        v[:children].each do |kk,vv|
          children = []
          child_klass = Object.const_get(vv[:class_name])
          items.each do |item|
            child_item =  item.send(kk.to_sym)
            #items = Object.const_get(vv[:class_name]).where("#{v[:class_name].underscore}_id = ANY(array[?])", items.pluck(:id))
            if child_item
              children.push(child_item)
              if vv[:has_attached_images]
                copy_attached_images([child_item] , vv)
              end
            end
          end
          build_csv("#{vv[:class_name].underscore}_csv", child_klass, [], children)
        end
      end
    end
    # zip up the files
    zip = zip_csv_files
    File.chmod(0644, @zip_path)
    # delete extra created files
    empty_created_files

    update_prepped_download_item

    private_channel = 'complete_' + @user_id.to_s
    #puts private_channel.inspect
    WebsocketRails[:downloadItems].trigger private_channel, @download_item

  end

  private

  TMP_PATH = "tmp/download_tmp"

  def update_prepped_download_item
    @download_item.update_attributes(file_location: @zip_path, processed: true)
  end

  def empty_created_files
    FileUtils::rm_rf TMP_PATH
  end

  def zip_csv_files
    Zip::File.open(@zip_path, Zip::File::CREATE) do |zipfile|
      Dir.foreach(TMP_PATH) do |item|
        next if item == "." or item == ".." or item == ".DS_Store"
        #puts item.inspect
        zipfile.add(item, "#{TMP_PATH}/#{item}")
      end
    end
  end

  # copies the attachments to the tmp folder
  def copy_attached_images(items, v)
    items.each do |item|
      attachment = item.send v[:attachment_name]
      if attachment.exists?
        extension = File.extname(attachment.path)
        fileName = File.basename(attachment.path, extension)
        tmpPath = "#{TMP_PATH}/#{item.id}_#{fileName}#{extension}"
        FileUtils::cp(attachment.path, tmpPath)
      end
    end
  end

  def ordered_attributes(column_names, item)
    r = []
    column_names.each do |c|
      r << item.send(c)
    end
    r
  end

  def build_csv(file_name, model, extra_attrs, items)
    file = CSV.generate(headers: true) do |csv|
      column_names = model.column_names
      headers = column_names.concat extra_attrs.map{|attr_hash| attr_hash[:header]}
      csv << headers
      if items.length > 0
        items.each do |item|

          attr_values = ordered_attributes(column_names, item).concat extra_attrs.map{|attr_hash| item.send(attr_hash[:func])}
          csv << attr_values
        end
      end
    end
    FileUtils::mkdir_p "#{TMP_PATH}"
    path = File.join("#{TMP_PATH}", "#{file_name}.csv")
    File.open(path, "wb") { |f| f.write(file)}
  end

  # def add_additional_attrs(headers, extra_attrs) do
  #   extra_attrs.each do |attr_hash|
  #     headers << attr_hash
  #   end
  # end

end