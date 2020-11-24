# == Schema Information
#
# Table name: option_properties
#
#  id                    :integer          not null, primary key
#  information           :text
#  short_label           :text
#  option_id             :integer          not null
#  property_id           :integer          not null
#  decision_aid_id       :integer          not null
#  created_by_user_id    :integer
#  updated_by_user_id    :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  information_published :text
#  ranking               :text
#  ranking_type          :integer
#  short_label_published :text
#  button_label          :string
#

class OptionProperty < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::RequiredByDecisionAid
  include Shared::Injectable
  include Shared::CrossCloneable

  belongs_to :option
  belongs_to :property
  belongs_to :decision_aid

  validates :option_id, :property_id, :decision_aid_id, :short_label, presence: true

  enum ranking_type: { integer: 0, question_response_value: 1 }

  # validates_numericality_of :ranking, :only_integer => true, :allow_nil => true, 
  #   :greater_than_or_equal_to => 1,
  #   :less_than_or_equal_to => 10,
  #   :message => "can only be whole number between 1 and 10."

  validates_uniqueness_of :property_id, scope: [:option_id, :decision_aid_id]
  validates_uniqueness_of :option_id, scope: [:property_id, :decision_aid_id]

  counter_culture :decision_aid

  has_many :decision_aid_user_option_properties, dependent: :destroy

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:information, :short_label].freeze
  attributes_with_attached_items OptionProperty::HAS_ATTACHED_ITEMS_ATTRIBUTES
  INJECTABLE_ATTRIBUTES = [:information_published, :short_label_published].freeze
  injectable_attributes OptionProperty::INJECTABLE_ATTRIBUTES

  # required_attributes "treatment_rankings" => [{val: :ranking_type, key: :ranking_type, message: "must include a ranking type"},
  #                                           {val: :ranking, key: :ranking, message: "must include a ranking value"}]

  validate :validate_ranking

  # Scope methods
  scope :for_standard_option_match, -> (option_ids, decision_aid_user_id) { 
    joins(:option)
      .where(options: {id: option_ids})
      .joins("LEFT OUTER JOIN decision_aid_user_properties as daup on daup.decision_aid_user_id = #{decision_aid_user_id} AND daup.property_id = option_properties.property_id")
      .joins("LEFT OUTER JOIN properties as prop on option_properties.property_id = prop.id")
      .select("option_properties.*, 
               (CASE WHEN daup.weight IS NOT NULL THEN daup.weight ELSE 0 END) as property_weight, 
               prop.are_option_properties_weighable as is_user_weighable") 
  }

  def generate_ranking_value(dau)
    case ranking_type
    when "integer"
      ranking.to_f
    when "question_response_value"
      id = ranking[/(?<=\[question id=\")[0-9]+(?=\"\])/]
      if id
        r = dau.decision_aid_user_responses
          .where(question_id: id)
          .joins("LEFT OUTER JOIN questions on questions.id = decision_aid_user_responses.question_id")
          .joins("LEFT OUTER JOIN question_responses on question_responses.id = decision_aid_user_responses.question_response_id")
          .select("decision_aid_user_responses.*, 
                   questions.question_response_type as question_response_type,
                   question_responses.numeric_value as numeric_value")
          .take
        if r and r.question_response_type
          if r.question_response_type == Question.question_response_types["lookup_table"]
            r.lookup_table_value 
          else
            r.numeric_value 
          end
        end
      else
        nil
      end
    end
  end

  def self.bulk_update_option_properties(update_hash, option_properties)
    r = []
    if update_hash != {}
      raise Exceptions::InvalidParams, "InvalidId" if option_properties.length != update_hash.length
      op_sql = []
      option_properties.each do |op|
        update_params = update_hash[op.id.to_s]
        op.update_attributes!(update_params)
        r.push op
      end
    end
    r
  end

  def self.bulk_create_option_properties(creation_params, decision_aid_id)
    r = []
    creation_params.each do |opp|
      op = OptionProperty.new(opp)
      op.decision_aid_id = decision_aid_id
      op.save!
      r.push op
    end
    r
  end

  private

  def validate_ranking
    if ranking
      case ranking_type
      when "integer"
        f = ranking.to_f
        # if f < 0.0 or f > 10.0
        #   errors.add(:ranking, "must be a decimal between 0 and 10")
        # end
      when "question_response_value"
        if (ranking =~ /\[question id=\"[0-9]+\"\]/).nil?
          errors.add(:ranking, "invalid format for question response value")
        end
      end
    end
  end
end
