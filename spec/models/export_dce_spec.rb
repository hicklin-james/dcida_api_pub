require "rails_helper"
require 'csv'
require 'zip'

RSpec.describe ExportDce, :type => :model do
  let! (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  describe "methods" do
    #@r = Redis.new
    #r = Redis::Namespace.new(:ns, :redis => @r)
    let (:num_question_sets) { 5 }
    let (:num_responses) { 2 }
    let (:num_blocks) { 1 }
    let (:download_item) { DownloadItem.create }
    let (:export_dce) { ExportDce.new(decision_aid, download_item, 1, num_question_sets, num_responses, num_blocks, false) }
    let (:tmp_file_path) {"#{Rails.root}/rspec_tmp" }

    before do
      @q = create(:demo_radio_question, decision_aid: decision_aid) 
      o1 = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, question_response_array: @q.question_responses.map(&:id))
      o2 = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, question_response_array: @q.question_responses.map(&:id))
      @p = create(:property_with_levels , decision_aid: decision_aid, property_order: 1)
      @p2 = create(:property_with_levels, decision_aid: decision_aid, property_order: 2)
      decision_aid.reload
    end

    def generate_template_files(exporter, file_name)
      r = exporter.create_dce_template_files
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
    
    describe "create_dce_template_files" do

      it "should save a file to the download_items folder" do
        tmp_count = Dir.glob(File.join(tmp_file_path, '**', '*')).select { |file| File.file?(file) }.count
        export_dce.create_dce_template_files
        new_count = Dir.glob(File.join(tmp_file_path, '**', '*')).select { |file| File.file?(file) }.count
        expect(new_count - tmp_count).to eq 1
      end

      describe "error handling" do

        # it "should throw an error if there are no options on the decision aid" do
        #   decision_aid.options.destroy_all
        #   expect(decision_aid.options_count).to eq 0
        #   exporter = ExportDce.new(decision_aid, download_item, 1, num_question_sets, num_responses, num_blocks)
        #   generate_template_files(exporter, "dce_design")
        #   expect(@e).to be_instance_of(Exceptions::DceExportError)
        #   expect(@e.message).to eq Exceptions::DceExportError::NO_OPTIONS
        # end

        it "should throw an error if there are no properties on the decision aid" do
          decision_aid.properties.destroy_all
          decision_aid.reload
          expect(decision_aid.properties_count).to eq 0
          exporter = ExportDce.new(decision_aid, download_item, 1, num_question_sets, num_responses, num_blocks, false)
          generate_template_files(exporter, "dce_design")
          expect(@e).to be_instance_of(Exceptions::DceExportError)
          expect(@e.message).to eq Exceptions::DceExportError::NO_PROPERTIES
        end

        it "should throw an error if there are no property levels on a property on the decision aid" do
          p3 = create(:property, decision_aid: decision_aid, property_order: 3)
          exporter = ExportDce.new(decision_aid.reload, download_item, 1, num_question_sets, num_responses, num_blocks, false)
          generate_template_files(exporter, "dce_design")
          expect(@e).to be_instance_of(Exceptions::DceExportError)
          expect(@e.message).to eq Exceptions::DceExportError::props_missing_levels([p3.title])
        end

        it "should throw an error if the num_question_sets is less than 1" do
          exporter = ExportDce.new(decision_aid.reload, download_item, 1, 0, num_responses, num_blocks, false)
          generate_template_files(exporter, "dce_design")
          expect(@e).to be_instance_of(Exceptions::DceExportError)
          expect(@e.message).to eq Exceptions::DceExportError::NUM_QUESTIONS_ZERO
        end

        it "should throw an error if the num_responses is less than 2" do
          exporter = ExportDce.new(decision_aid.reload, download_item, 1, num_question_sets, 1, num_blocks, false)
          generate_template_files(exporter, "dce_design")
          expect(@e).to be_instance_of(Exceptions::DceExportError)
          expect(@e.message).to eq Exceptions::DceExportError::NUM_RESPONSES_LESS_THAN_TWO
        end

      end

      describe "dce_design" do
        
        before do
          generate_template_files(export_dce, "dce_design")
        end

        it "has a question_set column" do
          headers = CSV.parse(@csv_data, headers: true).headers()
          expect(headers).to include("question_set")
        end

        it "has an answer column" do
          headers = CSV.parse(@csv_data, headers: true).headers()
          expect(headers).to include("answer")
        end

        it "has (num_question_sets*num_responses) rows + 3 + num_question_sets for the headers" do
          rows = CSV.parse(@csv_data)
          expect(rows.length).to eq((num_question_sets * num_responses) + 3 + num_question_sets)
        end

        # it "has fully unique rows" do
        #   rows = CSV.parse(@csv_data)
        #   expect(rows.to_a.map{|r| r.join("")}.uniq.length).to eq(rows.length)
        # end

        it "has all the properties listed" do
          prop_names = decision_aid.properties.pluck(:title)
          headers = CSV.parse(@csv_data, headers: true).headers()
          attribute_index = 1
          expect(prop_names.length).to be > 0
          prop_names.each do |pn|
            expect(headers).to include(pn)
          end
        end
      end

      describe "dce_results" do
        before do |example|
          unless example.metadata[:skip_default]
            generate_template_files(export_dce, "dce_results")
          end
        end

        it "has no question responses if there are no options dependent on question responses" do
          rows = CSV.parse(@csv_data)
          expect(rows[0]).to include("ID")
          expect(rows[0]).to include("weights")
        end

        def setup_question_dependent_option
          qrs = @q.question_responses.map(&:id)
          @option_with_sub_options = create(:option_with_sub_options, sub_decision_id: decision_aid.sub_decisions.first.id, sub_options_count: qrs.length, decision_aid: decision_aid, question_response_array: qrs)
          @option_with_sub_options.sub_options.each_with_index do |so, i|
            so.question_response_array = [qrs[i]]
            so.save
          end
          csv_data = nil
          generate_template_files(export_dce, "dce_results")
        end

        def create_template_files
          decision_aid.reload
          generate_template_files(export_dce, "dce_results")
        end

        it "has question responses for options dependent on question responses", skip_default: true do
          setup_question_dependent_option
          rows = CSV.parse(@csv_data)
          expect(rows[0]).to include(@q.question_text)
          expect(rows[3]).to include("ID")
          expect(rows[3]).to include("weights")
          expect(rows[1].uniq.length).to eq(1)
        end

        it "has a seperate set of sub-option for each unique question response combination", skip_default: true do
          setup_question_dependent_option
          rows = CSV.parse(@csv_data)
          counter = 0
          rows[4].each do |item|
            if item == @option_with_sub_options.title
              counter += 1
            end
          end
          expect(counter).to be > 0
          expect(counter).to eq(@option_with_sub_options.sub_options.length)
        end

        describe "has k^n rows after the header rows" do

          before do |example|
            exporter = ExportDce.new(decision_aid, download_item, 1, example.metadata[:questions], example.metadata[:answers], example.metadata[:blocks], false)
            generate_template_files(exporter, "dce_results")
          end

          it "has 32 rows with 2 answers and 5 question sets", skip_default: true, questions: 5, answers: 2, blocks: 1 do
            rows = CSV.parse(@csv_data)
            expect(rows.length).to eq(32 + 2) # add 4 for the header rows
          end

          it "has 64 rows with 2 answers and 6 question sets", skip_default: true, questions: 6, answers: 2, blocks: 1 do
            rows = CSV.parse(@csv_data)
            expect(rows.length).to eq(64 + 2)
          end
          it "has 59049 rows (3 ^ 10) with 4 answers and 10 question sets", skip_default: true, questions: 10, answers: 3, blocks: 1 do
            rows = CSV.parse(@csv_data)
            expect(rows.length).to eq(59049 + 2)
          end
        end
      end
    end
  end

end
