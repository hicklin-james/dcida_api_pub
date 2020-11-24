module Shared::Orderable
  extend ActiveSupport::Concern

  module ClassMethods

    def acts_as_orderable(position_column, order_scope_method)
      attr_accessor :update_order_after_destroy
      after_destroy :update_order_after_destroy_callback

      define_method "change_order" do |new_position|
        new_position = new_position.to_i
        old_position = send(position_column).to_i

        unless new_position == old_position || new_position < 0
          if old_position < new_position
            self.send(order_scope_method)
              .where("#{position_column} > #{old_position} AND #{position_column} <= #{new_position}")
              .update_all("#{position_column} = (#{position_column} - 1)")
          else
            self.send(order_scope_method)
              .where("#{position_column} >= #{new_position} AND #{position_column} < #{old_position}")
              .update_all("#{position_column} = (#{position_column} + 1)")
          end
          update_column position_column, new_position
        end
      end



      define_method "initialize_order" do |order_count|
        #max_order = send(order_scope_method).maximum(position_column)
        #if max_order.nil?
        #  write_attribute position_column, 1
        #else
        write_attribute position_column, (order_count + 1)
        #end
      end

      #define_method "initialize_order!" do
      #  initialize_order
      #  save(validate: false)
      #end

      define_method "remove_from_order" do
        self.send(order_scope_method)
          .where("#{position_column} > ?", self[position_column])
          .update_all("#{position_column} = (#{position_column} - 1)")
      end

      define_method "update_order_after_destroy_callback" do
        remove_from_order if update_order_after_destroy
        true
      end
    end

  end
end