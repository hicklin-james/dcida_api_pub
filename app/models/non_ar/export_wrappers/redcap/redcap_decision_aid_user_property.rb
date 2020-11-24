# == Schema Information
#
# Table name: decision_aid_user_properties
#
#  id                    :integer          not null, primary key
#  property_id           :integer          not null
#  decision_aid_user_id  :integer          not null
#  weight                :integer          default(50)
#  order                 :integer          not null
#  color                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  traditional_value     :float
#  traditional_option_id :integer
#

class RedcapDecisionAidUserProperty < DecisionAidUserProperty

  def get_relevant_value_for_target(decision_aid_type)
    case decision_aid_type
    when "standard", "treatment_rankings", "decide"
      self.weight
    when "dce", "best_worst", "traditional", "best_worst_no_results", "dce_no_results", "best_worst_with_prefs_after_choice"
      self.traditional_value
    else
      Rails.logger.error "Decision aid type <#{decision_aid_type}> not supported"
    end
  end

end
