require "rails_helper"
require 'csv'
require 'zip'

RSpec.describe ExportBw, :type => :model do
  let! (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  describe "methods" do
    #@r = Redis.new
    #r = Redis::Namespace.new(:ns, :redis => @r)
    let (:num_question_sets) { 5 }
    let (:num_attributes_per_question) { 3 }
    let (:download_item) { DownloadItem.create }
    let (:export_bw) { ExportBw.new(decision_aid, download_item, 1, num_question_sets, num_attributes_per_question, 1) }
    let (:tmp_file_path) {"#{Rails.root}/rspec_tmp" }

    before do
      @q = create(:demo_radio_question, decision_aid: decision_aid) 
      o1 = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, question_response_array: @q.question_responses.map(&:id))
      o2 = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, question_response_array: @q.question_responses.map(&:id))
      create_list(:property_with_levels, 6, decision_aid: decision_aid, property_order: 1)
      decision_aid.reload
    end

    def generate_template_files(exporter, file_name)
      r = exporter.create_bw_template_files
      if r[:success] == true
        @download_item = r[:download_item]
        Zip::File.open("#{Rails.root}/rspec_tmp/#{@download_item.file_location}") do |zip_file|
          entry = zip_file.glob("#{file_name}.csv").first
          @csv_data = entry.get_input_stream.read
        end
      else
        @e = r[:exception]
      end
    end
    
    describe "create_bw_template_files" do

      it "should save a file to the download_items folder" do
        tmp_count = Dir.glob(File.join(tmp_file_path, '**', '*')).select { |file| File.file?(file) }.count
        export_bw.create_bw_template_files
        new_count = Dir.glob(File.join(tmp_file_path, '**', '*')).select { |file| File.file?(file) }.count
        expect(new_count - tmp_count).to eq 1
      end

      describe "error handling" do

        it "should raise an exception if there are no properties" do
          decision_aid.properties.destroy_all
          decision_aid.reload
          expect(decision_aid.properties_count).to eq 0
          exporter = ExportBw.new(decision_aid, download_item, 1, num_question_sets, num_attributes_per_question, 1)
          generate_template_files(exporter, "Best-Worst Design")
          expect(@e).to be_instance_of(Exceptions::BwExportError)
          expect(@e.message).to eq Exceptions::BwExportError::NO_PROPERTIES
        end

        it "should raise an exception if any properties have no property levels" do
          p = create(:property, decision_aid: decision_aid) # property without a level
          exporter = ExportBw.new(decision_aid, download_item, 1, num_question_sets, num_attributes_per_question, 1)
          generate_template_files(exporter, "bw_design")
          expect(@e).to be_instance_of(Exceptions::BwExportError)
          expect(@e.message).to eq Exceptions::BwExportError::props_missing_levels([p.title])
        end

        it "should raise an exception if there are no options" do
          decision_aid.options.destroy_all
          decision_aid.reload
          expect(decision_aid.options_count).to eq 0
          exporter = ExportBw.new(decision_aid, download_item, 1, num_question_sets, num_attributes_per_question, 1)
          generate_template_files(exporter, "Best-Worst Design")
          expect(@e).to be_instance_of(Exceptions::BwExportError)
          expect(@e.message).to eq Exceptions::BwExportError::NO_OPTIONS
        end

        it "should raise an exception if the number of questions is zero" do
          exporter = ExportBw.new(decision_aid, download_item, 1, 0, num_attributes_per_question, 1)
          generate_template_files(exporter, "Best-Worst Design")
          expect(@e).to be_instance_of(Exceptions::BwExportError)
          expect(@e.message).to eq Exceptions::BwExportError::NUM_QUESTIONS_ZERO
        end

        it "should raise an exception if the number of attributes is zero" do
          exporter = ExportBw.new(decision_aid, download_item, 1, num_question_sets, 0, 1)
          generate_template_files(exporter, "Best-Worst Design")
          expect(@e).to be_instance_of(Exceptions::BwExportError)
          expect(@e.message).to eq Exceptions::BwExportError::NUM_ATTRIBUTES_ZERO
        end
      end

       describe "bw_design" do
        before do
          generate_template_files(export_bw, "Best-Worst Design")
        end

        it "has an Attributes per question column" do
          headers = CSV.parse(@csv_data, headers: true).headers()
          expect(headers).to include("Attributes per question")
        end

        it "has an Attribute levels column" do
          headers = CSV.parse(@csv_data, headers: true).headers()
          expect(headers).to include("Attribute levels")
        end

        it "has a Level ID row" do
          row = CSV.parse(@csv_data).second
          expect(row).to include("Level ID")
        end

        it "has the correct number of attributes per question set" do
          row_with_headers = CSV.parse(@csv_data, headers: true)[0]
          attr_val = row_with_headers.find {|r| r.first == "Attributes per question"}
          expect(attr_val).not_to be nil
          expect(attr_val.second.to_i).to eq num_attributes_per_question
        end

        it "has num property levels + 3 columns" do
          row = CSV.parse(@csv_data).second
          expect(row.length).to eq(PropertyLevel.count + 3)
        end

        it "has unique property level ids" do
          row = CSV.parse(@csv_data).second
          row_length = row.length
          ids = row[2..row_length]
          expect(ids.length).to eq(ids.uniq.length)
        end
      end
    end
  end
end