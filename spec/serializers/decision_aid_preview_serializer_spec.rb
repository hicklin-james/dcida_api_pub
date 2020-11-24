require 'rails_helper'

RSpec.describe DecisionAidSerializer, :type => :serializer do

  context 'decision aid preview representation' do
    let(:decision_aid) { build(:basic_decision_aid) }

    let(:serializer) { DecisionAidPreviewSerializer.new(decision_aid) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

    subject do
      JSON.parse(serialization.to_json)['decision_aid']
    end

    it 'has an about_information_published key' do
      expect(subject).to have_key 'about_information_published'
    end

    it 'has an options_information_published key' do
      expect(subject).to have_key 'options_information_published'
    end

    it 'has a description_published key' do
      expect(subject).to have_key 'description_published'
    end

    it 'has a properties_information_published key' do
      expect(subject).to have_key 'properties_information_published'
    end

    it 'has a property_weight_information_published key' do
      expect(subject).to have_key 'property_weight_information_published'
    end

    it 'has a minimum_property_count key' do
      expect(subject).to have_key 'minimum_property_count'
    end

    it 'has a chart_type key' do
      expect(subject).to have_key 'chart_type'
    end

    it 'has anratings_enabled key' do
      expect(subject).to have_key 'ratings_enabled'
    end

    it 'has a percentages_enabled key' do
      expect(subject).to have_key 'percentages_enabled'
    end

    it 'has a best_match_enabled key' do
      expect(subject).to have_key 'best_match_enabled'
    end

    it 'has a decision_aid_type key' do
      expect(subject).to have_key 'decision_aid_type'
    end

    it 'has a results_information_published key' do
      expect(subject).to have_key 'results_information_published'
    end

    it 'has an quiz_information_published key' do
      expect(subject).to have_key 'quiz_information_published'
    end

  end
end