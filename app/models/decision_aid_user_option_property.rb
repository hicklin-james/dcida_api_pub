# == Schema Information
#
# Table name: decision_aid_user_option_properties
#
#  id                   :integer          not null, primary key
#  option_property_id   :integer          not null
#  option_id            :integer          not null
#  property_id          :integer          not null
#  decision_aid_user_id :integer          not null
#  value                :float            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class DecisionAidUserOptionProperty < ApplicationRecord

  belongs_to :option_property
  belongs_to :option
  belongs_to :property
  belongs_to :decision_aid_user
  counter_culture :decision_aid_user

  validates :decision_aid_user_id, :property_id, :option_id, :option_property_id, :value, presence: true
  validates_numericality_of :value, 
    :less_than_or_equal_to => 10, 
    :greater_than_or_equal_to => 0, 
    :only_integer => false

  def self.update_values(update_params_hash, option_properties, decision_aid_user_id)
    ids = update_params_hash.map {|k,v| k}
    dauops = DecisionAidUserOptionProperty.where(id: ids, decision_aid_user_id: decision_aid_user_id)
    raise Exceptions::InvalidParams, "InvalidId" if dauops.length != ids.length
    dauop_sql = []
    dauops.each do |dauop|
      update_params = update_params_hash[dauop.id]
      if update_params
        if dauop.value != update_params["value"]
          # set the value so that the returned json has the updated value
          dauop.value = update_params["value"]
          # ensure that validations pass for the new value before adding
          # it to the SQL query
          if dauop.validate!
            dauop_sql.push "(#{dauop.id}, #{update_params['value']})"
          end
        end
      end
      option_properties.push dauop
    end
    if dauop_sql.length > 0
      # update all the values in one query - keeps speed good
      update_sql = "UPDATE decision_aid_user_option_properties AS t SET value = c.value FROM (VALUES #{dauop_sql.join(',')}) AS c(id, value) WHERE c.id = t.id"
      ActiveRecord::Base.connection.execute(update_sql)
    end
  end
end
