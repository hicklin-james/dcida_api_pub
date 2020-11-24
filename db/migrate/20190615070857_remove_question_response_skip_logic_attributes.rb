class RemoveQuestionResponseSkipLogicAttributes < ActiveRecord::Migration[4.2]
  def up
    QuestionResponse.all.each do |qr|
      if qr.has_skip_logic
        SkipLogicTarget.create!(target_entity: qr.skip_logic_type,
                               skip_question_id: qr.skip_question_id,
                               skip_page_url: qr.skip_page_url,
                               decision_aid_id: qr.decision_aid_id,
                               question_response_id: qr.id,
                               skip_logic_target_order: 1)
      end
    end

    remove_column :question_responses, :has_skip_logic, :boolean
    remove_column :question_responses, :skip_logic_type, :integer
    remove_column :question_responses, :skip_question_id, :integer
    remove_column :question_responses, :skip_page_url, :string
  end

  def down
    add_column :question_responses, :has_skip_logic, :boolean, default: false
    add_column :question_responses, :skip_logic_type, :integer
    add_column :question_responses, :skip_question_id, :integer
    add_column :question_responses, :skip_page_url, :string

    QuestionResponse.all.each do |qr|
      if qr.skip_logic_target_count > 0
        qr.has_skip_logic = true
        qr.skip_logic_type = SkipLogicTarget.target_entities[qr.skip_logic_targets.first.target_entity],
        qr.skip_question_id = qr.skip_logic_targets.first.skip_question_id,
        qr.skip_page_url = qr.skip_logic_targets.first.skip_page_url,
        qr.save!
      end
    end
  end
end
