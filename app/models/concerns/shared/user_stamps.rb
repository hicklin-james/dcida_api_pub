module Shared::UserStamps
  extend ActiveSupport::Concern

  included do
    before_validation :user_stamp_before_create, on: :create
    before_save :user_stamp_before_save

    belongs_to :creator, class_name: 'User', foreign_key: 'created_by_user_id', optional: true
    belongs_to :updater, class_name: 'User', foreign_key: 'updated_by_user_id', optional: true
  end

  def user_stamp_before_create
    if respond_to?(:created_by_user_id=) && ActiveRecord::Base.record_timestamps
      self.creator = User.current_user
    end
    true
  end

  def user_stamp_before_save
    if respond_to?(:updated_by_user_id=) && ActiveRecord::Base.record_timestamps
      self.updater = User.current_user
    end
    true
  end

  def created_by
    unless creator.nil?
      creator.full_name
    end
  end

  def updated_by
    unless updater.nil?
      updater.full_name
    end
  end

  def is_creator
    current_user = User.current_user
    !current_user.nil? && self.created_by_user_id == current_user.id
  end

  def is_updater
    current_user = User.current_user
    !current_user.nil? && self.updated_by_user_id == current_user.id
  end

end
