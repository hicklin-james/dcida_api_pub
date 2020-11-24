require "rails_helper"
require 'csv'
require 'set'

RSpec.describe BwImport, :type => :model do
  let (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }

  PROPERTY_LEVEL_COUNT ||= 5
  ATTRS_PER_QUESTION ||= 3

  describe "error handling" do
    describe "design upload" do
      
      before do
        create_list(:property_with_levels, PROPERTY_LEVEL_COUNT, decision_aid: decision_aid)
        @levels = decision_aid.property_levels
          .joins(:property)
          .select("property_levels.*, properties.title as property_title, properties.property_order as property_order")
          .order("property_order ASC, level_id ASC")
      end

      def random_1s(n, num_1s)
        a = []
        one_counter = 0
        n.times do |i|
          r = [0,1].sample
          if r == 1 && one_counter != num_1s
            a.push(r)
            one_counter += 1 
          else 
            a.push 0
          end
        end
        a
      end

      it "should raise a BwImportError if there is no Attributes per question header" do

        invalid_csv = ",blahblah,Attribute levels,,,,,,,,
          Level ID,#{ATTRS_PER_QUESTION},#{@levels.map(&:id).join(',')}
          Question Set,,#{@levels.map{|l| "#{l.property_title} - Level #{l.level_id}"}.join(',')}
          1,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          2,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          3,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          4,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          5,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          6,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          7,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          8,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          9,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          10,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          11,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          12,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.bw_design_file = design_file
        decision_aid.save
        e = BwImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::BwImportError)
        expect(e.message).to eq Exceptions::BwImportError::NO_ATTRIBUTES_PER_QUESTION_HEADER
        expect(BwQuestionSetResponse.count).to be 0
      end

      it "should raise a BwImportError if there is no Level ID label" do

        invalid_csv = ",Attributes per question,Attribute levels,,,,,,,,
          blahblah,#{ATTRS_PER_QUESTION},#{@levels.map(&:id).join(',')}
          Question Set,,#{@levels.map{|l| "#{l.property_title} - Level #{l.level_id}"}.join(',')}
          1,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          2,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          3,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          4,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          5,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          6,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          7,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          8,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          9,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          10,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          11,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
          12,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.bw_design_file = design_file
        decision_aid.save
        e = BwImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::BwImportError)
        expect(e.message).to eq Exceptions::BwImportError::NO_LEVEL_ID_LABEL
        expect(BwQuestionSetResponse.count).to be 0
      end

      it "should raise a BwImportError if there are an incorrect number of attrs per question in a row" do

        invalid_csv = ",Attributes per question,Attribute levels,,,,,,,,
Level ID,#{ATTRS_PER_QUESTION},#{@levels.map(&:id).join(',')}
Question Set,,#{@levels.map{|l| "#{l.property_title} - Level #{l.level_id}"}.join(',')}
1,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
2,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
3,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
4,,#{random_1s(@levels.length, ATTRS_PER_QUESTION+1).join(',')}
5,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
6,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
7,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
8,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
9,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
10,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
11,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
12,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}"
        design_file = StringIO.new(invalid_csv)
        decision_aid.bw_design_file = design_file
        decision_aid.save
        e = BwImport.new(decision_aid, 1).import_design
        expect(e).to be_instance_of(Exceptions::BwImportError)
        expect(e.message).to eq Exceptions::BwImportError::wrong_number_attributes(4, ATTRS_PER_QUESTION)
        expect(BwQuestionSetResponse.count).to be 0
      end

      it "shouldn't raise an error if the csv is fully valid" do
        valid_csv = ",Attributes per question,Attribute levels,,,,,,,,
Level ID,#{ATTRS_PER_QUESTION},#{@levels.map(&:id).join(',')}
Question Set,,#{@levels.map{|l| "#{l.property_title} - Level #{l.level_id}"}.join(',')}
1,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
2,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
3,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
4,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
5,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
6,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
7,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
8,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
9,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
10,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
11,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}
12,,#{random_1s(@levels.length, ATTRS_PER_QUESTION).join(',')}"

        design_file = StringIO.new(valid_csv)
        decision_aid.bw_design_file = design_file
        decision_aid.save
        r = BwImport.new(decision_aid, 1).import_design
        expect(r).to be_in([true, false])
        expect(BwQuestionSetResponse.count).to be > 0
      end
    end
  end

end