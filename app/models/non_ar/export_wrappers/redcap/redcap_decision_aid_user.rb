# == Schema Information
#
# Table name: decision_aid_users
#
#  id                                                 :integer          not null, primary key
#  decision_aid_id                                    :integer          not null
#  selected_option_id                                 :integer
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  decision_aid_user_responses_count                  :integer          default(0), not null
#  decision_aid_user_properties_count                 :integer          default(0), not null
#  decision_aid_user_option_properties_count          :integer          default(0), not null
#  decision_aid_user_dce_question_set_responses_count :integer          default(0), not null
#  decision_aid_user_bw_question_set_responses_count  :integer          default(0), not null
#  decision_aid_user_sub_decision_choices_count       :integer          default(0), not null
#  about_me_complete                                  :boolean          default(FALSE)
#  quiz_complete                                      :boolean          default(FALSE)
#  randomized_block_number                            :integer
#  unique_id_name                                     :integer
#  estimated_end_time                                 :datetime
#  other_properties                                   :text
#  platform                                           :string
#

class RedcapDecisionAidUser < DecisionAidUser

  VALID_ACCESSORS = ['other_properties']

  def get_relevant_value_for_target(data_accessor)
    if VALID_ACCESSORS.include?(data_accessor)
      return self.send(data_accessor)
    else
      return nil
    end
  end

end
