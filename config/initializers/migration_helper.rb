module Schema

  def self.included(base)
    ActiveRecord::ConnectionAdapters::Table.send :include, TableDefinition
    ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TableDefinition
    ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Statements
  end

  module TableDefinition
    # add custom table migration helpers here
    def userstamps
      column(:created_by_user_id, :integer)
      column(:updated_by_user_id, :integer)
    end

    def userstamps_uuid
      column(:created_by_user_id, :uuid)
      column(:updated_by_user_id, :uuid)
    end

    def archivable
      column(:is_archived, :boolean, null: false, default: false)
    end
  end

  module Statements
    # add migration statement helpers here (i.e. migrations that do not appear inside create_table)
    def add_userstamps(table_name)
      add_column(table_name, :created_by_user_id, :integer)
      add_column(table_name, :updated_by_user_id, :integer)
    end

    def add_userstamps_uuid(table_name)
      add_column(table_name, :created_by_user_id, :uuid)
      add_column(table_name, :updated_by_user_id, :uuid)
    end

    def remove_userstamps(table_name)
      remove_column(table_name, :created_by_user_id)
      remove_column(table_name, :updated_by_user_id)
    end

    def add_archivable(table_name)
      add_column(table_name, :is_archived, :boolean, null: false, default: false)
    end

    def remove_archivable(table_name)
      remove_column(table_name, :is_archived)
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, Schema)
end
