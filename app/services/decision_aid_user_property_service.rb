# The DecisionAidUserPropertyService class is the main helper class to the
# DecisionAidUserPropertiesController class. It deals with the heavy lifting
# as far as managing user properties goes.
class DecisionAidUserPropertyService

  def self.add_or_remove_user_properties(decision_aid_user, updated_properties, created_properties)
    final_items, items_to_destroy, items_to_update = [], [], []
    updated_id_weight_map = updated_properties.map{ |daup| {:id => daup[:id], 
                                                            :weight => daup[:weight], 
                                                            :order => daup[:order], 
                                                            :color => daup[:color], 
                                                            :traditional_value => daup[:traditional_value],
                                                            :traditional_option_id => daup[:traditional_option_id]
                                                          } 
                                                  }
    decision_aid_user.decision_aid_user_properties.each do |daup|
      keep_or_destroy_property_list(daup, updated_id_weight_map, items_to_destroy, items_to_update, final_items)
    end
    # Only create/update/destroy if there is a database transaction to make
    if created_properties.length > 0 or items_to_destroy.length > 0 or items_to_update.length > 0
      create_update_and_destroy_properties(final_items, created_properties, items_to_destroy, items_to_update)
    end

    final_items
  end

  private

  def self.keep_or_destroy_property_list(daup, updated_id_weight_map, items_to_destroy, items_to_update, final_items)
    # for each existing property, determine if it has been deleted
    # it has been deleted if it doesn't exist in the params
    this_id_w_map = updated_id_weight_map.find {|id_w_map| id_w_map[:id].to_i == daup.id}
    if !this_id_w_map
      items_to_destroy.push daup
    elsif this_id_w_map[:weight] != daup.weight or 
          this_id_w_map[:order] != daup.order or 
          this_id_w_map[:color] != daup.color or 
          this_id_w_map[:traditional_value] != daup.traditional_value or 
          this_id_w_map[:traditional_option_id] != daup.traditional_option_id 
          
      daup.weight = this_id_w_map[:weight]
      daup.order = this_id_w_map[:order]
      daup.color = this_id_w_map[:color]
      daup.traditional_value = this_id_w_map[:traditional_value]
      daup.traditional_option_id = this_id_w_map[:traditional_option_id]
      items_to_update.push daup
    else
      final_items.push daup
    end
  end

  def self.create_update_and_destroy_properties(final_items, created_properties, deleted_properties, updated_properties)
    DecisionAidUserProperty.transaction do
      DecisionAidUserProperty.batch_delete_user_properties(deleted_properties)
      final_items.push *DecisionAidUserProperty.batch_save_user_properties(updated_properties)
      final_items.push *DecisionAidUserProperty.batch_create_user_properties(created_properties)
    end
  end
end