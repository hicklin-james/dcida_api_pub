class AddPublishedAccordionFieldsToModels < ActiveRecord::Migration[4.2]
  def change
    add_column :decision_aids, :description_published, :text
    add_column :decision_aids, :about_information_published, :text
    add_column :decision_aids, :options_information_published, :text
    add_column :decision_aids, :properties_information_published, :text
    add_column :decision_aids, :property_weight_information_published, :text
    add_column :decision_aids, :results_information_published, :text
    add_column :decision_aids, :quiz_information_published, :text
    add_column :options, :description_published, :text
    add_column :options, :summary_text_published, :text
    add_column :option_properties, :information_published, :text
    add_column :properties, :selection_about_published, :text
    add_column :properties, :long_about_published, :text
    add_column :questions, :question_text_published, :text
    add_column :accordion_contents, :content_published, :text
  end
end
