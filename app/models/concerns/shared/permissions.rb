module Shared::Permissions
  extend ActiveSupport::Concern

  def get_decision_aid_id
    da_id = nil
    if self.respond_to?(:decision_aid_id)
      da_id = self.decision_aid_id
    elsif self.instance_of?(DecisionAid)
      da_id = self.id
    else
      puts "No decision_aid_id on object of type: #{self.class.to_s}"
    end
    return da_id
  end

  included do
    UserPermission.permission_values.each do |k, v|
      define_method "can_#{k}" do |user|
        da_id = self.get_decision_aid_id()
        return if da_id.nil?
        user.is_superadmin || UserPermission.where(decision_aid_id: da_id, user_id: user.id, permission_value: v).count > 0
      end
    end
  end
end