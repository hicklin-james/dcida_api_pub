# == Schema Information
#
# Table name: question_pages
#
#  id                      :integer          not null, primary key
#  section                 :integer
#  question_page_order     :integer          not null
#  decision_aid_id         :integer          not null
#  created_by_user_id      :integer
#  updated_by_user_id      :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  skip_logic_target_count :integer          default(0), not null
#

class QuestionPageSerializer < ActiveModel::Serializer
  attributes :id,
    :section,
    :decision_aid_id,
    :question_page_order,
    :page_questions,
    :skip_logic_targets,
    :skip_logic_target_count

  def skip_logic_targets
    if !instance_options[:skip_skip_logic_targets]
      slts = object.skip_logic_targets.ordered
      slts.map do |slt| 
        s = SkipLogicTargetSerializer.new(slt)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
        adapter.as_json
      end
    end
  end

  def page_questions
    if instance_options[:include_questions]
      object.questions.ordered.map do |q| 
        q = QuestionListSerializer.new(q)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(q)
        adapter.as_json
      end
    else
      []
    end
  end
end
