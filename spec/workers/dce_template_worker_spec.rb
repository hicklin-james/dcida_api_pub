require 'rails_helper'

RSpec.describe DceTemplateWorker do

  let! (:decision_aid) { create(:basic_decision_aid, slug: "test_decision_aid") }
  let (:user) { create(:user) }
  let (:num_question_sets) { 5 }
  let (:num_responses) { 2 }
  let (:num_blocks) { 1 }
  let (:download_item) { DownloadItem.create }
  #let (:export_dce) { ExportDce.new(decision_aid, download_item, 1, num_question_sets, num_responses, num_blocks) }
  #let (:tmp_file_path) {"#{Rails.root}/rspec_tmp" }

  before do
    @q = create(:demo_radio_question, decision_aid: decision_aid) 
    o1 = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, question_response_array: @q.question_responses.map(&:id))
    o2 = create(:option, decision_aid: decision_aid, sub_decision_id: decision_aid.sub_decisions.first.id, question_response_array: @q.question_responses.map(&:id))
    @p = create(:property_with_levels , decision_aid: decision_aid, property_order: 1)
    @p2 = create(:property_with_levels, decision_aid: decision_aid, property_order: 2)
    decision_aid.reload
  end

  after do
    ### DON'T UNCOMMENT THE IFS. IT DELETES THE ENTIRE REPOSITORY!!
    if ExportDce::TMP_PATH and !ExportDce::TMP_PATH.blank?
      FileUtils::rm_rf "#{ExportDce::TMP_PATH}"
    end
  end

  it "enqueues a DceTemplateWorker" do
    DceTemplateWorker.perform_async(num_question_sets, num_responses, num_blocks, false, decision_aid.id, download_item.id, user.id)
    expect(DceTemplateWorker.jobs.size).to eq 1
  end

  it "should perform a job" do
    r = DceTemplateWorker.new.perform(num_question_sets, num_responses, num_blocks, false, decision_aid.id, download_item.id, user.id)  
    expect(r).to have_key :success
    expect(r[:success]).to be true
  end 
end