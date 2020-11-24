class CreateIntroPages < ActiveRecord::Migration[4.2]
  
  def up
    create_table :intro_pages do |t|
    	t.text         :description
    	t.text         :description_published
    	t.belongs_to   :decision_aid
    	t.integer	   :intro_page_order

      t.timestamps null: false
      t.userstamps
    end

    DecisionAid.all.each do |da|
    	#default all the intro_pages order to 1
    	IntroPage.create!(decision_aid_id: da.id, description: da.description, description_published: da.description_published, intro_page_order: 1)
    end
  end

  def down
    DecisionAid.all.each do |da|
      if intro_page = da.intro_pages.first
        da.update_attributes!(description: intro_page.description, description_published: intro_page.description_published)
      end
    end
    drop_table :intro_pages
  end
end
