require 'tempfile'

class AddCustomCssFileToDecisionAids < ActiveRecord::Migration[4.2]
  def up
    change_table :decision_aids do |t|
      t.has_attached_file :custom_css_file
    end

    DecisionAid.all.each do |da|
    	file = Tempfile.new('custom_css.css')
    	file.write(da.custom_css)
    	file.close
    	da.custom_css_file = File.open(file.path)
    	da.save!
    	file.unlink
    end

  end

  def down
    drop_attached_file :decision_aids, :custom_css_file
  end
end
