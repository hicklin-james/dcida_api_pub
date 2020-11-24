class CreateDceQuestionSets < ActiveRecord::Migration[4.2]
  def change
    create_table :dce_question_sets do |t|
      t.belongs_to :decision_aid
      t.string :question_title
      t.integer :dce_question_set_order
      t.timestamps null: false
    end
    add_reference :dce_question_set_responses, :dce_question_set, index: true
    DceQuestionSetResponse.all.sort_by(&:block_number).group_by(&:decision_aid_id).each do |k, responses|
      grouped_responses = responses.group_by(&:question_set)
      grouped_responses.each do |kk, rs|
      	# k is decision_aid_id
      	# kk is question_set
      	nqs = DceQuestionSet.new(decision_aid_id: k, dce_question_set_order: kk, question_title: "Question Set #{kk}")
      	nqs.save
      	rs.each do |r|
      		r.dce_question_set_id = nqs.id
      		r.save
      	end
      end
    end
  end
end
