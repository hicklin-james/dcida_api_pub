class AddShortLabelPublishedToOptionProperty < ActiveRecord::Migration[4.2]
  def change
  	add_column :option_properties, :short_label_published, :text
  end
end
