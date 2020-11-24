class CreateDecisionAidUserQueryParameters < ActiveRecord::Migration[4.2]
  def up
    create_table :decision_aid_query_parameters do |t|
      t.string :input_name
      t.string :output_name
      t.boolean :is_primary

      t.belongs_to :decision_aid
    end

    create_table :decision_aid_user_query_parameters do |t|

      t.string :param_value 
      t.belongs_to :decision_aid_query_parameter
      t.belongs_to :decision_aid_user
    end

    DecisionAid.all.each do |da|
      qp = DecisionAidQueryParameter.create(input_name: "pid", output_name: "pid", is_primary: true, decision_aid_id: da.id)
      ups = da.decision_aid_users.where.not(pid: nil).map{|dau| {param_value: dau["pid"], decision_aid_user_id: dau.id, decision_aid_query_parameter_id: qp.id}}
      DecisionAidUserQueryParameter.create(ups)
    end
  end

  def down
    remove_table :decision_aid_query_parameters
    remove_table :decision_aid_user_query_parameters
  end
end
