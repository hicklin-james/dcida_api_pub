class ChangeDecisionAidUserPropertyNullFields < ActiveRecord::Migration[4.2]
  def change
    change_column_null :decision_aid_user_properties, :decision_aid_user_id, false
    change_column_null :decision_aid_user_properties, :property_id, false
  end
end
