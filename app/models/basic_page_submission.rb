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

class BasicPageSubmission < ApplicationRecord
  
  belongs_to :decision_aid_user

  # belongs to one or the other
  belongs_to :intro_page, optional: true
  belongs_to :option, optional: true
  belongs_to :sub_decision, optional: true

  validates :intro_page_id, uniqueness: {scope: :decision_aid_user_id}, if: -> {intro_page_id}
  validates :option_id, uniqueness: {scope: :decision_aid_user_id}, if: -> {option_id}

  validate :singular_belongs_to_intro_or_option

  private

  def singular_belongs_to_intro_or_option
    if (self.intro_page_id and self.option_id) or (!self.intro_page_id and !self.option_id)
      errors.add(:basic_page_submission, "Must belong to one of intro_page or option")
    end
  end

end
