module Shared::CrossCloneable
  extend ActiveSupport::Concern

  module ClassMethods
    
    def cross_clone_hash(attributes)
      class_columns = self.column_names
      h = Hash.new
      class_columns.each do |cn|
        if attributes.key?(cn) and cn != "id"
          h[cn] = attributes[cn]
        end
      end
      self.new(h)
    end
  end
end