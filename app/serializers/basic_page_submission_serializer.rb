# == Schema Information
#
# Table name: basic_page_submissions
#
#  id                   :integer          not null, primary key
#  decision_aid_user_id :integer
#  option_id            :integer
#  sub_decision_id      :integer
#  intro_page_id        :integer
#

class BasicPageSubmissionSerializer < ActiveModel::Serializer

  attributes :id,
    :decision_aid_user_id,
    :option_id,
    :sub_decision_id,
    :intro_page_id

end
