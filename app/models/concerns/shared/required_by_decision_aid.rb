module Shared::RequiredByDecisionAid
  extend ActiveSupport::Concern

  module ClassMethods

    def required_attributes(att_type_hash)

      validate :required_validator

      define_method "required_validator" do
        da = self.respond_to?(:decision_aid) ? self.decision_aid : self
        if da
          atts = att_type_hash[da.decision_aid_type]
          if atts and atts.length > 0
            atts.each do |att|
              att_val = send(att[:val])
              if att_val.nil?
                errors.add(att[:key], att[:message])
              end
            end
          end
        end
      end
    end
  end
end