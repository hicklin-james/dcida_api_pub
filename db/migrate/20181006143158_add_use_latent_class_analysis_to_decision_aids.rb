class AddUseLatentClassAnalysisToDecisionAids < ActiveRecord::Migration[4.2]
  def change
  	add_column :decision_aids, :use_latent_class_analysis, :boolean, default: false
  end
end
