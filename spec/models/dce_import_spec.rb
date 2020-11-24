require "rails_helper"
require 'csv'

RSpec.describe DceImport, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  PROPERTY_LEVEL_COUNT ||= 5
  OPTION_COUNT ||= 3
  QUESTION_SET_LENGTH ||= 5

  describe "error handling" do
    describe "design upload" do
      before do
        create_list(:property_with_levels, PROPERTY_LEVEL_COUNT, decision_aid: decision_aid)
      end

      it "should raise a DceImportError if the question_set header is missing" do
        invalid_csv = 
          " ,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::DESIGN_HEADERS_MISSING
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if the answer header is missing" do
        invalid_csv = 
          "question_set, ,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , ,, ID,#{decision_aid.properties.map(&:id).join(",")}
            , ,, Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::DESIGN_HEADERS_MISSING
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if the block header is missing" do
        invalid_csv = 
          "question_set,answer, , ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::DESIGN_HEADERS_MISSING
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if a property id is missing" do
        ids = decision_aid.properties.map(&:id)
        ids.pop()
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{ids.join(",")}, 
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::INVALID_PROPERTY_ID
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if a property id is an invalid id" do
        ids = decision_aid.properties.map(&:id)
        ids[ids.length-1] = -1
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{ids.join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::INVALID_PROPERTY_ID
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if the property ids don't match the titles" do
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).reverse.join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::PROPERTY_TITLE_ID_BAD_MATCH
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if a property title is incorrect with respect to the decision aid property titles" do
        titles = decision_aid.properties.map(&:title)
        titles[titles.length-1] = "LOL"
        invalid_csv = 
          "question_set,answer,block, ,#{titles.join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).reverse.join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::PROP_TITLE_MISSING
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if a property title is missing" do
        titles = decision_aid.properties.map(&:title)
        titles.pop
        invalid_csv = 
          "question_set,answer,block, ,#{titles.join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).reverse.join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::PROP_TITLE_MISSING
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if the maximum value is not the actual maximum value" do
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count + 1}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::MAX_PROPERTY_LEVEL_INCORRECT
      end

      it "should raise a DceImportError if a level is greater than the property_level length" do
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*2..PROPERTY_LEVEL_COUNT+1].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::PROPERTY_LEVEL_OUT_OF_RANGE
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if there is an unequal number of answers per question set" do
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}
            2,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::UNEQUAL_ANSWERS_PER_SET
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if there is no ID row" do
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , , ,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::missing_label('ID')
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise a DceImportError if there is no Maximum Value row" do
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , , ,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::missing_label('Maximum Value')
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "should raise an ActiveRecord::RecordInvalid if multiple rows have the same answer and question set" do
        invalid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(ActiveRecord::RecordInvalid)
        expect(DceQuestionSetResponse.count).to be 0
      end

      it "shouldn't raise an error if csv file is fully valid" do
        valid_csv = 
          "question_set,answer,block, ,#{decision_aid.properties.map(&:title).join(",")}
            , , ,ID,#{decision_aid.properties.map(&:id).join(",")}
            , , ,Maximum Value,#{decision_aid.properties.map{|p| p.property_levels.count}.join(",")}
            1,1,1, ,#{[*1..PROPERTY_LEVEL_COUNT].join(",")}
            1,2,1, ,#{[*1..PROPERTY_LEVEL_COUNT].reverse.join(",")}"
        design_file = StringIO.new(valid_csv)
        decision_aid.dce_design_file = design_file
        decision_aid.save
        r = DceImport.new(decision_aid, 1).import_design
        expect(r).to be_in([true, false])
        expect(DceQuestionSetResponse.count).to be > 0
      end
    end

    describe "results upload" do
      before do
        create(:demo_radio_question, decision_aid: decision_aid)
        create_list(:property_with_levels, PROPERTY_LEVEL_COUNT, decision_aid: decision_aid)
        create_list(:option, OPTION_COUNT, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id)
      end
      
      it "should raise a DceImportError if the weights header is missing" do
        props_length = decision_aid.properties.length
        invalid_csv =
          " , , , , , ,#{Array.new(props_length, " ").join(",")},ID,#{decision_aid.options.map(&:id).join(",")}
          question_set_1,question_set_2,question_set_3,question_set_4,question_set_5,#{decision_aid.properties.map(&:title).join(",")}, ,Option Name,#{decision_aid.options.map(&:title).join(",")}
          1,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1"

        results_file = StringIO.new(invalid_csv)
        decision_aid.dce_results_file = results_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_results
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::missing_label('weights')
        expect(DceResultsMatch.count).to be 0
      end

      it "should raise a DceImportError if the ID header is missing" do
        props_length = decision_aid.properties.length
        invalid_csv =
          " , , , , ,weights,#{Array.new(props_length, " ").join(",")}, ,#{decision_aid.options.map(&:id).join(",")}
          question_set_1,question_set_2,question_set_3,question_set_4,question_set_5,#{decision_aid.properties.map(&:title).join(",")}, ,Option Name,#{decision_aid.options.map(&:title).join(",")}
          1,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1"

        results_file = StringIO.new(invalid_csv)
        decision_aid.dce_results_file = results_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_results
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::missing_label('ID')
        expect(DceResultsMatch.count).to be 0
      end

      # it "should raise a DceImportError if a row has no option selected" do
      #   props_length = decision_aid.properties.length
      #   invalid_csv =
      #     " , , , , ,weights,#{Array.new(props_length, " ").join(",")},ID,#{decision_aid.options.map(&:id).join(",")}
      #     question_set_1,question_set_2,question_set_3,question_set_4,question_set_5,#{decision_aid.properties.map(&:title).join(",")}, ,Option Name,#{decision_aid.options.map(&:title).join(",")}
      #     1,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, , 
      #     1,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     1,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
      #     2,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1"

      #   results_file = StringIO.new(invalid_csv)
      #   decision_aid.dce_results_file = results_file
      #   decision_aid.save
      #   e = DceImport.new(decision_aid, 1).import_results
      #   expect(e).to be_instance_of(Exceptions::DceImportError)
      #   expect(e.message).to eq Exceptions::DceImportError::missing_option_label(2)
      #   expect(DceResultsMatch.count).to be 0
      # end

      it "should raise a DceImportError if the option id row is missing some option ids" do
        props_length = decision_aid.properties.length
        ids = decision_aid.options.map(&:id)
        ids[ids.length-1] = -1 
        invalid_csv =
          " , , , , ,weights,#{Array.new(props_length, " ").join(",")},ID,#{ids.join(",")}
          question_set_1,question_set_2,question_set_3,question_set_4,question_set_5,#{decision_aid.properties.map(&:title).join(",")}, ,Option Name,#{decision_aid.options.map(&:title).join(",")}
          1,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1"

        results_file = StringIO.new(invalid_csv)
        decision_aid.dce_results_file = results_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_results
        expect(e).to be_instance_of(Exceptions::DceImportError)
        expect(e.message).to eq Exceptions::DceImportError::MISSING_OPTION_ID_ROW
        expect(DceResultsMatch.count).to be 0
      end

      it "should raise an ActiveRecord::RecordInvalid if multiple rows have the same response combiation" do
        props_length = decision_aid.properties.length
        invalid_csv =
          " , , , , ,weights,#{Array.new(props_length, " ").join(",")},ID,#{decision_aid.options.map(&:id).join(",")}
          question_set_1,question_set_2,question_set_3,question_set_4,question_set_5,#{decision_aid.properties.map(&:title).join(",")}, ,Option Name,#{decision_aid.options.map(&:title).join(",")}
          1,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1 
          1,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1"

        results_file = StringIO.new(invalid_csv)
        decision_aid.dce_results_file = results_file
        decision_aid.save
        e = DceImport.new(decision_aid, 1).import_results
        expect(e).to be_instance_of(ActiveRecord::RecordInvalid)
        #expect(e.message).to eq Exceptions::DceImportError::MISSING_OPTION_ID_ROW
        expect(DceResultsMatch.count).to be 0
      end

      it "shouldn't raise an error if the csv is fully valid" do
        props_length = decision_aid.properties.length
        valid_csv =
          " , , , , ,weights,#{Array.new(props_length, " ").join(",")},ID,#{decision_aid.options.map(&:id).join(",")}
          question_set_1,question_set_2,question_set_3,question_set_4,question_set_5,#{decision_aid.properties.map(&:title).join(",")}, ,Option Name,#{decision_aid.options.map(&:title).join(",")}
          1,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          1,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,1,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,1,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,1,2,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,1,#{Array.new(props_length+2, " ").join(",")}, ,1
          2,2,2,2,2,#{Array.new(props_length+2, " ").join(",")}, ,1"

        results_file = StringIO.new(valid_csv)
        decision_aid.dce_results_file = results_file
        decision_aid.save
        r = DceImport.new(decision_aid, 1).import_results
        expect(r).to be_in([true, false])
        expect(DceResultsMatch.count).to be > 0
      end
    end
  end
end