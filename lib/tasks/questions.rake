namespace :questions do
  task :create_heatmap_question, [:decision_aid_id, :question_type] => :environment do |t, args|
    if args[:decision_aid_id] and args[:question_type]
      parent_q = Question.new(
        decision_aid_id: args[:decision_aid_id].to_i, 
        question_type: args[:question_type].to_s,
        question_response_type: "grid",
        question_response_style: "normal_grid",
        special_flag: "body_heatmap",
        question_text: "TEST HEATMAP QUESTION"
      )
      parent_q.initialize_order(parent_q.order_scope.count)
      parent_q.skip_validate_grid_questions = true

      parent_q.save!
      parent_q.reload

      body_parts = ['neck', 'lshoulder', 'lelbow', 'lwrist', 'lhand', 'lthumb', 'lhip', 'lknee', 'lankle', 'lfoot',
      'rshoulder', 'relbow', 'rwrist', 'rhand', 'rthumb', 'rhip', 'rknee', 'rankle', 'rfoot',
      'uback', 'lback']

      body_parts.each do |bp|
        child = Question.new(
          decision_aid_id: args[:decision_aid_id].to_i, 
          question_type: args[:question_type].to_s,
          question_response_type: "yes_no",
          question_response_style: "normal_yes_no",
          question_id: parent_q.id,
          question_order: 1,
          question_text: bp
        )
        child.skip_validate_responses_length = true
        child.save!
        child.reload

        r1 = QuestionResponse.new(
          decision_aid_id: args[:decision_aid_id].to_i, 
          question_response_order: 1,
          question_response_value: "yes",
          question_id: child.id
        )

        r2 = QuestionResponse.new(
          decision_aid_id: args[:decision_aid_id].to_i, 
          question_response_order: 2,
          question_response_value: "no",
          question_id: child.id
        )

        r1.save!
        r2.save!
      end

      puts "Question created".green
    else
      puts "Invalid parameters".red
    end
  end
end