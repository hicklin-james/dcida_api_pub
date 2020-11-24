# == Schema Information
#
# Table name: options
#
#  id                      :integer          not null, primary key
#  title                   :string           not null
#  label                   :string
#  description             :text
#  summary_text            :text
#  decision_aid_id         :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  media_file_id           :integer
#  question_response_array :integer          default([]), is an Array
#  description_published   :text
#  summary_text_published  :text
#  option_order            :integer
#  option_id               :integer
#  has_sub_options         :boolean          not null
#  sub_decision_id         :integer
#  generic_name            :string
#

class Option < ApplicationRecord
  include Shared::UserStamps
  include Shared::HasAttachedItems
  include Shared::Orderable
  include Shared::Injectable
  include Shared::CrossCloneable

  belongs_to :decision_aid
  belongs_to :media_file, optional: true
  belongs_to :sub_decision

  counter_culture :decision_aid,
    :column_names => {
      ["options.has_sub_options = ?", false] => "options_count"
    },
    :column_name => Proc.new {|model| !model.has_sub_options? ? 'options_count' : nil}

  before_create :init_order

  validates :decision_aid_id, :title, :sub_decision, presence: true
  validate :validate_option_count
  #validates_presence_of :option_order, :if => "option_id.nil?"

  has_many :basic_page_submissions, dependent: :destroy

  has_many :option_properties, dependent: :destroy
  
  has_many :sub_options, -> { order(:option_order) }, dependent: :destroy, inverse_of: :option, class_name: "Option"
  belongs_to :option, inverse_of: :sub_options, optional: true
  accepts_nested_attributes_for :sub_options, allow_destroy: true

  has_many :decision_aid_users, foreign_key: "selected_option_id", dependent: :nullify
  has_many :decision_aid_user_option_properties, dependent: :destroy

  scope :ordered, ->{ order(sub_decision_id: :asc, option_order: :asc) }

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:description, :summary_text].freeze
  attributes_with_attached_items Option::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:description_published, :summary_text_published].freeze
  injectable_attributes Option::INJECTABLE_ATTRIBUTES

  acts_as_orderable :option_order, :order_scope
  attr_writer :update_order_after_destroy

  before_save :validate_sub_options

  def sub_option_ids
    if self.sub_options.loaded?
      self.sub_options.map(&:id)
    else
      self.sub_options.pluck(:id)
    end
  end

  def original_image_url
    url_prefix + self.media_file.image(:original) unless self.media_file.nil? || self.media_file.image.nil?
  end

  def results_image_url
    url_prefix + self.media_file.image(:result) unless self.media_file.nil? || self.media_file.image.nil?
  end

  def clone_option(da)
    option_dup = self.dup
    option_dup.initialize_order(da.options_count)

    begin
      Option.transaction do
        option_dup.save!
        option_dup.change_order(self.option_order + 1)
        if self.has_sub_options
          clone_sub_options(option_dup)
        end
      end
      {option: option_dup.reload}
    rescue => error
      {errors: [{"#{error.class}" => error.message}]}
    end
  end

  # def self.update_orders(id_order_array)
  #   ids = id_order_array.map{|q| q[:id]}
  #   raise Exceptions::InvalidParams, "InvalidId" if Option.where(id: ids).length != id_order_array.length
  #   o_sql = []
  #   id_order_array.each do |o|
  #     o_sql.push "(#{o[:id]}, #{o[:option_order]})"
  #   end

  #   # quickly update the orders without hitting the database loads of times
  #   # will be useful with large option sets
  #   update_sql = "UPDATE options AS t SET option_order = c.option_order FROM (VALUES #{o_sql.join(',')}) AS c(id, option_order) WHERE c.id = t.id"
  
  #   ActiveRecord::Base.connection.execute(update_sql)
  # end

  private

  def init_order
    initialize_order(Option.where(decision_aid_id: decision_aid_id, option_id: option_id).count)
  end

  def clone_sub_options(cloned_option)
    self.sub_options.each do |so|
      so_clone = so.dup
      so.option_id = cloned_option.id
      so.save!
    end
  end

  def validate_sub_options
    if self.has_sub_options
      # if we now have sub options, we should destroy
      # the option properties associated with the super option
      # to keep the counts in check
      self.option_properties.destroy_all
    else
      self.sub_options.destroy_all
    end
  end

  def validate_option_count
    da = self.decision_aid
    if da and self.new_record? and da.decision_aid_type == 'traditional' and Option.where(decision_aid_id: da.id, option_id: nil).count >= 2
      errors.add(:decision_aid, "can only have 2 options in traditional decision aid")
    end
  end

  def update_order_after_destroy
    true
  end

  def order_scope
    Option.where(decision_aid_id: decision_aid_id, option_id: option_id, sub_decision_id: sub_decision_id).order(option_order: :asc)
  end

  def url_prefix
    RequestStore.store[:protocol] + RequestStore.store[:host_with_port]
  end
  
end
