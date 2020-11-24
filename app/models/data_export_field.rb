# == Schema Information
#
# Table name: data_export_fields
#
#  id                      :integer          not null, primary key
#  exporter_id             :integer          not null
#  exporter_type           :string           not null
#  decision_aid_id         :integer          not null
#  data_target_type        :integer          not null
#  data_export_field_order :integer          not null
#  redcap_field_name       :string
#  redcap_response_mapping :json
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_accessor           :string
#

class DataExportField < ApplicationRecord
  include Shared::UserStamps
  include Shared::Orderable

  ALLOWED_TYPES = %w(Question Property SummaryPage Other).freeze

  # validations
  validates :data_target_type, :decision_aid_id, :exporter_id, :data_export_field_order, presence: true
  validates :exporter_type, presence: true, inclusion: {in: ALLOWED_TYPES}
  validate :validate_per_data_target

  counter_culture :decision_aid

  enum data_target_type: {redcap: 0}

  belongs_to :exporter, polymorphic: true, optional: true
  belongs_to :decision_aid

  default_scope { order(data_export_field_order: :asc) }

  acts_as_orderable :data_export_field_order, :order_scope
  attr_writer :update_order_after_destroy

  scope :list_scope, -> { 
    select("data_export_fields.*, 
      ( CASE 
        WHEN que.id IS NOT NULL 
          THEN 
            CASE 
            WHEN (que.backend_identifier <> '') IS NOT TRUE
              THEN 'Question ' || que.id
            ELSE
              que.backend_identifier
            END
        WHEN pro.id IS NOT NULL 
          THEN
            CASE 
            WHEN (pro.backend_identifier <> '') IS NOT TRUE
              THEN 'Property ' || pro.id
            ELSE
              pro.backend_identifier
            END
        WHEN spa.id IS NOT NULL 
          THEN
            CASE 
            WHEN (spa.backend_identifier <> '') IS NOT TRUE
              THEN 'Summary page ' || spa.id
            ELSE
              spa.backend_identifier
            END
        ELSE 'N/A' 
      END ) backend_identifier")
    .joins("LEFT OUTER JOIN questions que ON ( que.id = data_export_fields.exporter_id AND data_export_fields.exporter_type = 'Question' )")
    .joins("LEFT OUTER JOIN properties pro ON ( pro.id = data_export_fields.exporter_id AND data_export_fields.exporter_type = 'Property' )")
    .joins("LEFT OUTER JOIN summary_pages spa ON ( spa.id = data_export_fields.exporter_id AND data_export_fields.exporter_type = 'SummaryPage' )")
  }

  def self.grouped_by_data_target(target_ids)
    DataExportField.where(id: target_ids)
      .group_by{|obj| obj.data_target_type}
  end

  def exporter
    if self.exporter_type == 'Other'
      "Other"
    else
      super
    end
  end

  private

  def update_order_after_destroy
    true
  end

  def order_scope
    DataExportField.where(decision_aid_id: decision_aid_id).order(data_export_field_order: :asc)
  end

  def validate_per_data_target
    case self.data_target_type
    when "redcap"
      if !redcap_field_name
        self.errors.add(:redcap_field_name, "must be defined")
      end
    end
  end

end
