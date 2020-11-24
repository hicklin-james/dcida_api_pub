# == Schema Information
#
# Table name: decision_aid_user_sub_decision_choices
#
#  id                   :integer          not null, primary key
#  decision_aid_user_id :integer
#  sub_decision_id      :integer
#  option_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class DecisionAidUserSubDecisionChoice < ApplicationRecord

  validates :decision_aid_user_id, :sub_decision_id, :option_id, presence: true
  validates :sub_decision_id, uniqueness: {scope: :decision_aid_user_id}

  belongs_to :decision_aid_user
  belongs_to :sub_decision, optional: true

  counter_culture :decision_aid_user

  after_save :update_next_sub_decision_choices_if_needed

  private

  def update_next_sub_decision_choices_if_needed
    sd = self.sub_decision
    pt = ProgressTracker.where(decision_aid_user_id: self.decision_aid_user_id).includes(:section_trackers).take
    next_sd = SubDecision.where(decision_aid_id: sd.decision_aid_id, sub_decision_order: sd.sub_decision_order + 1).take
    if next_sd and pt
      if !next_sd.required_option_ids.include?(self.option_id)
        DecisionAidUserSubDecisionChoice.joins(:sub_decision)
          .where("sub_decisions.sub_decision_order > ?", sd.sub_decision_order)
          .where(decision_aid_user_id: self.decision_aid_user_id)
          .destroy_all
        pt.section_trackers.joins(:sub_decision)
          .where("sub_decisions.sub_decision_order > ?", sd.sub_decision_order)
          .destroy_all
      else
        # add section trackers to progress tracker if needed
        if !pt.section_trackers.exists?(sub_decision_id: next_sd.id)
          
          st = SectionTracker.create!(progress_tracker_id: pt.id, sub_decision_id: next_sd.id, page: "my_choice")
          current_section = pt.section_trackers.where(sub_decision_id: sd.id).take
           #st.section_tracker_order
          st.change_order(current_section.section_tracker_order + 1)

        end
      end
    end
  end
end
