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

class DecisionAidUserSerializer < ActiveModel::Serializer

  attributes :id,
    :selected_option_id,
    :pid,
    :decision_aid_user_sub_decision_choices_count,
    :other_properties

  # def pid
  #   object.decision_aid_user_query_parameters.joins("LEFT OUTER JOIN decision_aid_query_parameters as daqp on decision_aid_user_query_parameters.id = daqp.id AND daqp.is_primary = true").select("decision_aid_user_query_parameters.param_value").param_value
  # end

end
