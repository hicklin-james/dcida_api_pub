class AddUnitsArrayToQuestions < ActiveRecord::Migration[4.2]
  def up
    add_column :questions, :units_array, :string, array: true, default: []
    add_column :decision_aid_user_responses, :selected_unit, :string

    Question.all.each do |q|
      if q.unit_of_measurement
        units_array = [q.unit_of_measurement]
        q.units_array = units_array
        q.save!

        DecisionAidUserResponse.where(question_id: q.id).update_all(selected_unit: q.unit_of_measurement)
      end
    end
  end

  def down
    Question.all.each do |q|
      if q.units_array.length > 0
        q.unit_of_measurement = q.units_array[0]
        q.save!
      end
    end

    remove_column :questions, :units_array
    remove_column :decision_aid_user_responses, :selected_unit
  end
end
