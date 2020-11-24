class AddLookupTableDimensionsArray < ActiveRecord::Migration[4.2]
  def up
    add_column :questions, :lookup_table_dimensions, :integer, array: true, default: []
  
    Question.where(question_response_type: Question.question_response_types[:lookup_table]).each do |q|
      lookup_table_dimensions = []
      if q.lookup_table_x
        lookup_table_dimensions.push q.lookup_table_x
      end
      if q.lookup_table_y
        lookup_table_dimensions.push q.lookup_table_y
      end
      q.lookup_table_dimensions = lookup_table_dimensions
      q.save
    end
  end

  def down
    remove_column :questions, :lookup_table_dimensions
  end
end

