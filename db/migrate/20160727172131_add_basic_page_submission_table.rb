class AddBasicPageSubmissionTable < ActiveRecord::Migration[4.2]
  def change
    create_table :basic_page_submissions do |t|
      t.belongs_to :decision_aid_user
      t.belongs_to :option
      t.belongs_to :sub_decision
      t.belongs_to :intro_page
    end
  end
end
