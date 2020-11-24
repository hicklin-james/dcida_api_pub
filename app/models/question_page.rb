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

class QuestionPage < ActiveRecord::Base
  include Shared::UserStamps
  include Shared::Orderable
  include Shared::CrossCloneable

  belongs_to :decision_aid
  has_many :questions, dependent: :destroy
  has_many :decision_aid_user_skip_results, dependent: :destroy, foreign_key: "target_question_page_id"
  has_many :skip_logic_targets, dependent: :destroy, inverse_of: :question_page
  
  enum section: {about: 1, quiz: 2}

  validates :decision_aid, :section, :question_page_order, presence: true

  acts_as_orderable :question_page_order, :order_scope
  attr_writer :update_order_after_destroy

  accepts_nested_attributes_for :skip_logic_targets, allow_destroy: true

  scope :ordered, ->{ order(question_page_order: :asc) }

  def update_order_after_destroy
    true
  end

  def order_scope
    QuestionPage.where(decision_aid_id: self.decision_aid_id, section: QuestionPage.sections[self.section]).order(question_page_order: :asc)
  end

  def get_next_question_page(decision_aid_user, questions_in_page, indexed_responses_for_questions, section)

    # First check response skip logic
    questions_in_page.each do |q|
      response = indexed_responses_for_questions[q.id]
      if response and response.question_response
        response.question_response.skip_logic_targets.ordered.each do |slt|
          case slt.target_entity
          when "question_page"
            return {skipTo: "question_page", question_page: QuestionPage.find(slt.skip_question_page_id)}
          when "end_of_questions"
            return {skipTo: "end_of_questions", question_page: nil}
          when "external_page"
            url_to_use = if slt.include_query_params
                           daqps = decision_aid_user.decision_aid_user_query_parameters.includes(:decision_aid_query_parameter)
                           qps = daqps.map{|qp| "#{qp.decision_aid_query_parameter.output_name}=#{qp.param_value}"}.join("&")
                           slt.skip_page_url + qps
                         else
                           slt.skip_page_url
                         end
            return {skipTo: "external_page", question_page: nil, url_to_use: url_to_use}
          when "other_section"
            return {skipTo: "other_section", question: nil, url_to_use: slt.skip_page_url}
          end
        end
      end
    end

    # next check for generic question page skip logic
    self.skip_logic_targets.ordered.each do |slt|
      skipConditionMet = slt.evaluate_skip_logic_target(decision_aid_user)
      if skipConditionMet
        case slt.target_entity
        when "question_page"
          return {skipTo: "question_page", question_page: QuestionPage.find(slt.skip_question_page_id)}
        when "end_of_questions"
          return {skipTo: "end_of_questions", question_page: nil}
        when "external_page"
          url_to_use = if slt.include_query_params
                           daqps = decision_aid_user.decision_aid_user_query_parameters.includes(:decision_aid_query_parameter)
                           qps = daqps.map{|qp| "#{qp.decision_aid_query_parameter.output_name}=#{qp.param_value}"}.join("&")
                           slt.skip_page_url + qps
                         else
                           slt.skip_page_url
                         end
          return {skipTo: "external_page", question_page: nil, url_to_use: url_to_use}
        when "other_section"
          return {skipTo: "other_section", question: nil, url_to_use: slt.skip_page_url}
        end
      end
    end

    # no skip conditions defined, so just go to next page
    nextqp = QuestionPage.where(
      decision_aid_id: self.decision_aid_id,
      section: QuestionPage.sections[section],
      question_page_order: self.question_page_order + 1
    )

    if nextqp.length > 0
      return {skipTo: nil, question_page: nextqp.first}
    else
      return {skipTo: nil, question_page: nil}
    end
  end

end
