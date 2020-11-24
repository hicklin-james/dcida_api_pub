# == Schema Information
#
# Table name: decision_aid_user_skip_results
#
#  id                      :integer          not null, primary key
#  source_question_page_id :integer          not null
#  decision_aid_user_id    :integer          not null
#  target_type             :integer          not null
#  target_question_page_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class DecisionAidUserSkipResult < ApplicationRecord
  belongs_to :source_question, class_name: "Question", optional: true

  enum target_type: {question_page: 1, end_of_questions: 2, external_page: 3, other_section: 4}

  def self.create_or_update_or_delete(decision_aid_user, source_question_page_id, target_type, target_question_page)
    existingSkipResult = DecisionAidUserSkipResult.where(decision_aid_user_id: decision_aid_user.id, source_question_page_id: source_question_page_id)
    skipped = target_type

    # there is already one - either update or delete
    if existingSkipResult.count > 0
      existingSkipResult = existingSkipResult.first

      if skipped
        existingSkipResult.update_attributes(source_question_page_id: source_question_page_id, 
                                             target_type: target_type, 
                                             target_question_page_id: (target_question_page ? target_question_page.id : nil),
                                             updated_at: DateTime.now)
      else
        existingSkipResult.destroy
      end
    else
      if skipped
        DecisionAidUserSkipResult.create(source_question_page_id: source_question_page_id, 
                                         target_type: target_type, 
                                         target_question_page_id: (target_question_page ? target_question_page.id : nil),
                                         decision_aid_user_id: decision_aid_user.id)
      end
    end

    if !skipped and target_question_page
      DecisionAidUserSkipResult.where(decision_aid_user_id: decision_aid_user.id,
                                      target_question_page_id: target_question_page.id,
                                      target_type: DecisionAidUserSkipResult.target_types["question_page"]).destroy_all
    end

    # delete any that are on the same page and skipped before that were overriden by the current skip
    if source_question_page_id
      # get latest updated record
      latest_record_id = DecisionAidUserSkipResult.where(
        decision_aid_user_id: decision_aid_user.id, 
        source_question_page_id: source_question_page_id
      ).order('updated_at DESC').limit(1).pluck(:id)
      
      # delete everything else
      DecisionAidUserSkipResult.where(
        decision_aid_user_id: decision_aid_user.id, 
        source_question_page_id: source_question_page_id
      ).where.not(id: latest_record_id).destroy_all
    end

  end
end
