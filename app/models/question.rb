# == Schema Information
#
# Table name: questions
#
#  id                           :integer          not null, primary key
#  question_text                :text
#  question_type                :integer          not null
#  question_response_type       :integer          not null
#  question_order               :integer          not null
#  decision_aid_id              :integer          not null
#  created_by_user_id           :integer
#  updated_by_user_id           :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  question_text_published      :text
#  question_id                  :integer
#  grid_questions_count         :integer          default(0), not null
#  hidden                       :boolean          default(FALSE)
#  response_value_calculation   :string
#  lookup_table                 :json
#  question_response_style      :integer
#  sub_decision_id              :integer
#  lookup_table_dimensions      :integer          default([]), is an Array
#  remote_data_source           :boolean          default(FALSE)
#  remote_data_source_type      :integer
#  redcap_field_name            :string
#  my_sql_procedure_name        :string
#  current_treatment_option_ids :integer          default([]), is an Array
#  slider_left_label            :string
#  slider_right_label           :string
#  slider_granularity           :integer
#  num_decimals_to_round_to     :integer          default(0)
#  can_change_response          :boolean          default(TRUE)
#  post_question_text           :text
#  post_question_text_published :text
#  slider_midpoint_label        :string
#  unit_of_measurement          :string
#  side_text                    :text
#  side_text_published          :text
#  skippable                    :boolean          default(FALSE)
#  special_flag                 :integer          default(1), not null
#  is_exclusive                 :boolean          default(FALSE)
#  randomized_response_order    :boolean          default(FALSE)
#  min_number                   :integer
#  max_number                   :integer
#  min_chars                    :integer
#  max_chars                    :integer
#  units_array                  :string           default([]), is an Array
#  remote_data_target           :boolean          default(FALSE)
#  remote_data_target_type      :integer
#  backend_identifier           :string
#  question_page_id             :integer
#

#require 'ruby-prof'

class Question < ApplicationRecord
  include Shared::UserStamps
  include Shared::Orderable
  include Shared::HasAttachedItems
  include Shared::Injectable
  include Shared::CrossCloneable

  enum question_response_type: { radio: 0, text: 1, grid: 2, number: 3, lookup_table: 4, yes_no: 5, current_treatment: 6, json: 7, heading: 8, slider: 9, ranking: 10, sum_to_n: 11 }
  enum question_response_style: { horizontal_radio: 0, vertical_radio: 1, normal_text: 2, normal_grid: 3, normal_number: 4, normal_lookup_table: 5, 
    normal_yes_no: 6, normal_current_treatment: 7, normal_json: 8, normal_heading: 9, horizontal_slider: 10, vertical_slider: 11, dropdown_radio: 12, 
    normal_ranking: 13, horizontal_sum_to_n: 14, vertical_sum_to_n: 15, stacking_sum_to_n: 16 }
  enum question_type: { demographic: 0, quiz: 1}
  enum remote_data_source_type: {redcap: 0, my_sql: 1, chatbot: 2}
  enum remote_data_target_type: {redcap_t: 0}
  enum special_flag: {normal: 1, body_heatmap: 2}

  belongs_to :decision_aid, inverse_of: :questions
  belongs_to :question, inverse_of: :grid_questions, optional: true
  belongs_to :sub_decision, optional: true
  belongs_to :question_page, optional: true # TODO remove this since this isn't really optional, but tests fail otherwise

  counter_culture :decision_aid,
    :column_name => Proc.new{|model| 
      if !model.hidden
        model.question_type == "demographic" ? 'demographic_questions_count' : 'quiz_questions_count'
      else
        nil
      end
    },
    :column_names => {
      ["questions.question_type = ? AND questions.hidden is FALSE and questions.question_id IS NULL", 0] => "demographic_questions_count",
      ["questions.question_type = ? AND questions.hidden is FALSE AND questions.question_id IS NULL", 1] => "quiz_questions_count"
    }

  counter_culture :question,
    :column_name => Proc.new{|model| !model.question_id.nil? ? 'grid_questions_count' : nil},
    :column_names => {
      ["questions_questions.question_id IS NOT ?", nil] => 'grid_questions_count'
    }

  validates :decision_aid_id, :question_response_type, :question_order, :question_type, :question_response_style, :num_decimals_to_round_to, presence: true
  validates :lookup_table, if: -> {question_response_type == 'lookup_table'}, presence: true
  validates :sub_decision_id, if: -> {question_response_type == 'current_treatment'}, presence: true
  # validates :slider_granularity, :if => "question_response_type == 'slider'", presence: true
  has_many :question_responses, dependent: :destroy, inverse_of: :question
  has_many :grid_questions, -> {order(:question_order => :asc)}, dependent: :destroy, inverse_of: :question, class_name: "Question"
  has_many :decision_aid_user_responses
  #has_many :decision_aid_user_skip_results, dependent: :destroy, foreign_key: "target_question_id"
  has_many :my_sql_question_params, -> {order(:my_sql_question_param_order => :asc)}, dependent: :destroy
  # has_many :skip_logic_targets, dependent: :destroy, inverse_of: :question
  has_many :data_export_fields, as: :exporter, dependent: :destroy

  scope :ordered, ->{ order(question_order: :asc) }

  accepts_nested_attributes_for :question_responses, allow_destroy: true
  accepts_nested_attributes_for :grid_questions, allow_destroy: true
  #accepts_nested_attributes_for :skip_logic_targets, allow_destroy: true

  HAS_ATTACHED_ITEMS_ATTRIBUTES = [:question_text, :post_question_text, :side_text].freeze
  attributes_with_attached_items Question::HAS_ATTACHED_ITEMS_ATTRIBUTES

  INJECTABLE_ATTRIBUTES = [:question_text_published, :post_question_text_published, :side_text_published].freeze
  injectable_attributes Question::INJECTABLE_ATTRIBUTES

  before_save :delete_grid_questions, if: -> {question_response_type != 'grid'}
  before_save :delete_responses, if: -> {question_response_type != 'radio' && question_response_type != 'yes_no' && question_response_type != 'ranking' && question_response_type != 'sum_to_n'}
  after_create :update_decision_aid_users_create
  after_destroy :update_decision_aid_users_destroy
  before_update :update_question_order, if: -> {hidden_changed?}

  attr_accessor :skip_validate_grid_questions
  attr_accessor :skip_validate_responses_length

  validate :validate_grid_questions, if: -> {question_response_type == 'grid'}, unless: :skip_validate_grid_questions
  validate :validate_responses_length, if: -> {question_response_type == 'radio' || question_response_type == 'ranking' || question_response_type == 'sum_to_n'}, unless: :skip_validate_responses_length
  validate :validate_response_type, if: -> {question_id}
  validate :validate_hidden_question, if: -> {hidden}
  validate :validate_non_hidden_question, if: -> {!hidden}
  validate :validate_lookup_table_dimensions, if: -> {question_response_type == 'lookup_table'}
  validate :validate_yes_no_responses_length, if: -> {question_response_type == 'yes_no'}, unless: :skip_validate_responses_length
  validate :validate_current_treatment_length, if: -> {question_response_type == 'current_treatment'}
  validate :validate_slider_question, if: -> {question_response_type == 'slider'}
  validate :validate_sum_to_n, if: -> {question_response_type == 'sum_to_n'}
  validate :validate_question_response_style
  validate :validate_units_array
  validate :validate_remote_data_source_and_target
  validate :question_page_valid

  acts_as_orderable :question_order, :order_scope
  attr_writer :update_order_after_destroy

  scope :get_related_hidden_questions, -> (question_ids) {
    where("(questions.question_response_type = 4 AND questions.lookup_table_dimensions <@ ARRAY#{question_ids}) 
        OR 
        (questions.question_response_type != 4 AND 
        (SELECT array_agg(i) from (select (regexp_matches(questions.response_value_calculation, '\\[question_([0-9]+)', 'g'))[1] i) as foo)::integer[] && ARRAY#{question_ids})
        OR
        (questions.question_response_type = 3 AND (questions.response_value_calculation NOT LIKE '%question%'))
        ")
  }

  def self.batch_create_and_update_hidden_responses(questions, decision_aid_user)
    # eager load questions and question responses
    daurs = decision_aid_user.reload.decision_aid_user_responses
      .includes(:question, :question_response)
      .to_a

    questions_with_existing_responses = Question.where(id: questions.map(&:id)).joins(:decision_aid_user_responses)
      .where(decision_aid_id: decision_aid_user.decision_aid_id)
      .where("decision_aid_user_responses.question_id = questions.id AND decision_aid_user_responses.decision_aid_user_id = #{decision_aid_user.id}")
      .select("questions.*, decision_aid_user_responses.id as response_id")   
    existing_question_ids = questions_with_existing_responses.map{|q| q.id}
    questions_with_missing_responses = questions.reject{|q| existing_question_ids.include?(q.id)}

    all_questions_sorted = (questions_with_existing_responses + questions_with_missing_responses).uniq.sort_by{|q| q.question_order}

    if all_questions_sorted.length > 0
      update_responses = []
      create_responses = []
      all_questions_sorted.each do |q|
        s = q.calculate_hidden_value(decision_aid_user, (q.respond_to?(:response_id) ? q.response_id : nil), daurs)

        if s
          unsaved_daur = s[:unsaved_daur]
          index = daurs.find_index{|daur| daur.question_id == unsaved_daur.question_id}
          if index
            daurs[index] = unsaved_daur
          else
            daurs.push unsaved_daur
          end

          # if unsaved_daur.question_id == 484
          #   puts "\n\n\n\nAdded lookup table response to all responses\nunsaved_daur: #{unsaved_daur.inspect}\n\n\n\n"
          # end

          sql_string = s[:sql]
          if q.respond_to?(:response_id) and q.response_id
            update_responses.push sql_string
          else
            create_responses.push sql_string
          end
        end
      end
      if !update_responses.empty?
        inner_update_sql = update_responses.join(",")
        update_query = "UPDATE decision_aid_user_responses as m set
            decision_aid_user_id = c.decision_aid_user_id, 
            question_id = c.question_id, 
            number_response_value = c.number_response_value, 
            question_response_id = c.question_response_id, 
            lookup_table_value = c.lookup_table_value, 
            updated_at = c.updated_at
          from (
            values
            #{inner_update_sql}
          ) as c(id, decision_aid_user_id, question_id, number_response_value, question_response_id, lookup_table_value, updated_at)
          where c.id = m.id
          "
        ActiveRecord::Base.connection.execute(update_query)
      end

      if !create_responses.empty?
        inner_create_sql = create_responses.join(",")
        create_sql = "INSERT INTO decision_aid_user_responses (decision_aid_user_id, question_id, number_response_value, question_response_id, lookup_table_value, created_at, updated_at) VALUES #{inner_create_sql}"
        ActiveRecord::Base.connection.execute(create_sql)
      end
    end
  end

  def self.get_remote_data_targets(question_ids)
    DataExportField.where(exporter_id: question_ids, exporter_type: "Question")
  end

  def generate_mysql_params(decision_aid_user, response_hash)
    my_sql_params = self.my_sql_question_params.ordered
    params = my_sql_params.map{|msp|
      p = msp.create_input_param(decision_aid_user, response_hash)
      return nil if p == ""
      "'" + p + "'"
    }.join(",")
  end

  def clone_question(da)
    cloned_question = self.dup

    question_atts = question_type == "demographic" ?
        {question_type: "quiz", count: da.quiz_questions_count} :
        {question_type: "demographic", count: da.demographic_questions_count}
    
    cloned_question.question_type = question_atts[:question_type]
    cloned_question.initialize_order(question_atts[:count])

    begin
      ActiveRecord::Base.transaction do
        cloned_question.skip_validate_responses_length = true
        cloned_question.skip_validate_grid_questions = true
        cloned_question.save!
        if question_response_type == "grid"
          duplicate_grid_questions(question_atts, cloned_question)
        else
          duplicate_responses(self, cloned_question)
        end
        {error: nil, question: cloned_question}
      end
    rescue => e
      {error: e}
    end
  end

  def calculate_hidden_value(decision_aid_user, daurid=nil, responses=nil)
    case self.question_response_type
    when "radio", "number", "yes_no", "slider", "text"
      calculate_radio_or_numeric_hidden_value(decision_aid_user, daurid, responses)
    when "lookup_table"
      calculate_lookup_table_hidden_value(decision_aid_user, daurid, responses)
    else
      nil
    end
  end

  # def get_next_question_page(dau, response, decision_aid, question_page_section)

  #   # First check response skip logic
  #   if response.question_response
  #     response.question_response.skip_logic_targets.ordered.each do |slt|
  #       case slt.target_entity
  #       when "question"
  #         return {skipTo: "question", question: Question.find(slt.skip_question_id)}
  #       when "end_of_questions"
  #         return {skipTo: "end_of_questions", question: nil}
  #       when "external_page"
  #         return {skipTo: "external_page", question: nil, url_to_use: slt.skip_page_url}
  #       when "other_section"
  #         return {skipTo: "other_section", question: nil, url_to_use: slt.skip_page_url}
  #       end
  #     end
  #   end

  #   # next check for generic question skip logic
  #   self.skip_logic_targets.ordered.each do |slt|
  #     skipConditionMet = slt.evaluate_skip_logic_target(dau)
  #     if skipConditionMet
  #       case slt.target_entity
  #       when "question"
  #         return {skipTo: "question", question: Question.find(slt.skip_question_id)}
  #       when "end_of_questions"
  #         return {skipTo: "end_of_questions", question: nil}
  #       when "external_page"
  #         return {skipTo: "external_page", question: nil, url_to_use: slt.skip_page_url}
  #       when "other_section"
  #         return {skipTo: "other_section", question: nil, url_to_use: slt.skip_page_url}
  #       end
  #     end
  #   end
  # end

  def order_scope
    Question.where(decision_aid_id: self.decision_aid_id, 
                   hidden: self.hidden, 
                   question_id: nil, 
                   question_type: Question.question_types[self.question_type],
                   question_page_id: self.question_page_id)
    .order(question_order: :asc)
  end

  private

  def correct_syntax?(code)
    stderr = $stderr
    $stderr.reopen(IO::NULL)
    RubyVM::InstructionSequence.compile(code)
    true
  rescue Exception
    false
  ensure
    $stderr.reopen(stderr)
  end

  def calculate_lookup_table_hidden_value(decision_aid_user, daurid, responses)
    # responses = decision_aid_user.decision_aid_user_responses
    #   .select{|r| self.lookup_table_dimensions.include?(r.question_id) }
    #   .sort_by {|r| self.lookup_table_dimensions.index(r.question_id)}

    sorted_responses = responses.select{|r| self.lookup_table_dimensions.include?(r.question_id) }
      .sort_by {|r| self.lookup_table_dimensions.index(r.question_id)}

    puts "\n\n\n\n\nQuestion id: #{self.id}\nLookup table dimensions: #{self.lookup_table_dimensions.inspect}"
    puts "#{sorted_responses.inspect}\n\n\n\n\n"

    rv = nil
    i = 0
    curr = nil

    while i < sorted_responses.length
      r = sorted_responses[i]
      curr = curr ? curr[r.question_response_id.to_s] : lookup_table[r.question_response_id.to_s]
      if curr
        if i == sorted_responses.length - 1
          rv = curr
        end
        i += 1
      else
        break
      end
    end

    get_update_params(decision_aid_user.id, nil, nil, rv, daurid)
  end

  def calculate_radio_or_numeric_hidden_value(decision_aid_user, daurid, responses)
    question_ids = find_question_ids
    if responses.nil?
      responses = decision_aid_user.decision_aid_user_responses
    end
    rvh = generate_response_value_hash(decision_aid_user, question_ids, responses)

    generated_string = generate_executable_string(rvh)
    #puts "\n\n\n\nquestion_ids: #{question_ids}\nresponses: #{responses}\ncalculation: #{self.response_value_calculation}\nrvh: #{rvh}\ngenerated string: #{generated_string}\n\n\n\n"

    # do everything in floats so that we can round it out later
    begin
      rv = correct_syntax?(generated_string) ? eval(generated_string) : nil
    rescue
      puts "CALCULATION DIDN'T GO AS PLANNED"
      rv = nil
    end

    # if self.id == 483
    #   puts "\n\n\n\nrv: #{rv}\n\n\n\n"
    # end

    qr = self.question_responses.find{|qr| qr.numeric_value == rv.to_i}

    if self.question_response_type == "number" or self.question_response_type == "slider"
      get_update_params(decision_aid_user.id, rv, nil, nil, daurid)
    elsif qr and (self.question_response_type == "radio" or self.question_response_type == "yes_no")
      get_update_params(decision_aid_user.id, nil, qr.id, nil, daurid)
    else
      nil
    end
  end

  def self.ordered_questions_without_grid(da, question_type)
    da.questions
      .joins("LEFT OUTER JOIN questions as parent_questions on questions.question_id = parent_questions.id")
      .where(question_type: question_type)
      .where("questions.question_response_type != #{Question.question_response_types[:grid]}")
      .order("CASE WHEN questions.question_id is NULL THEN questions.question_order ELSE parent_questions.question_order END ASC,
              CASE WHEN questions.question_id is NULL THEN NULL ELSE questions.question_order END ASC")
  end

  def correct_syntax?(code)
    stderr = $stderr
    $stderr.reopen(IO::NULL)
    RubyVM::InstructionSequence.compile(code)
    true
  rescue Exception
    false
  ensure
    $stderr.reopen(stderr)
  end

  # def generate_response_value_hash(decision_aid_user, question_ids)
  #   # 1. left join decision_aid_user_responses with question_responses and questions
  #   # 2. filter by question_ids in response_value_calculation
  #   # 3. create alias column determine_response_value for responses
  #   # 4. convert to hash with question_id as key and determined_response_value as value 
  #   r = decision_aid_user.decision_aid_user_responses
  #     .joins("LEFT OUTER JOIN question_responses as qr on qr.id = decision_aid_user_responses.question_response_id")
  #     .joins("LEFT OUTER JOIN questions as q on q.id = decision_aid_user_responses.question_id")
  #     .where(question_id: question_ids)
  #     .select("decision_aid_user_responses.*, 
  #             CASE WHEN q.question_response_type = #{Question.question_response_types[:number]} 
  #             THEN decision_aid_user_responses.number_response_value 
  #             ELSE qr.numeric_value END 
  #             as determined_response_value")
  #     .map{|r| [r.question_id, r.determined_response_value] }
  #     .to_h
  # end

  def update_existing_hidden_response(r, decision_aid_user_id, nrv, qrid, lookup_table_value)
    r.update_attributes!(
      decision_aid_user_id: decision_aid_user_id,
      question_id: self.id,
      number_response_value: nrv.respond_to?(:to_f) ? nrv : nil,
      question_response_id: qrid,
      lookup_table_value: lookup_table_value.respond_to?(:to_f) ? lookup_table_value : nil
    )
  end

  def generate_response_value_hash(decision_aid_user, question_ids, responses)
    value_hash = Hash.new
    responses.select{|r| question_ids.include?(r.question_id)}.each do |daur|
      rv = nil
      if daur.question.question_response_type == "number" || daur.question.question_response_type == "slider"
        rv = daur.number_response_value.to_f
      elsif daur.question.question_response_type == "json"
        #puts "FOUND A JSON QUESTION"
        rv = daur.json_response_value
      elsif daur.question.question_response_type == "lookup_table"
        rv = daur.lookup_table_value
      elsif daur.question.question_response_type == "text"
        rv = ( daur.response_value.blank? ? 0 : 1 )
      else
        rv = daur.question_response.numeric_value
      end
      value_hash[daur.question_id] = rv
    end
    value_hash
  end

  def get_update_params(decision_aid_user_id, nrv, qrid, lookup_table_value, daurid)
    _nrv = (!nrv.blank? && nrv.respond_to?(:to_f) ? nrv.to_f : nil)
    _lookup_table_value = (!lookup_table_value.blank? && lookup_table_value.respond_to?(:to_f) ? lookup_table_value.to_f : nil)

    if daurid
      s = "(#{daurid},#{decision_aid_user_id},#{self.id},#{!nrv.blank? && nrv.respond_to?(:to_f) ? _nrv : 'NULL::integer'},#{qrid ? qrid : 'NULL::integer'},#{!lookup_table_value.blank? && lookup_table_value.respond_to?(:to_f) ? _lookup_table_value : 'NULL::integer'},'#{Time.now.to_s(:db)}'::timestamp)"
    else
      s = "(#{decision_aid_user_id},#{self.id},#{!nrv.blank? && nrv.respond_to?(:to_f) ? _nrv : 'NULL::integer'},#{qrid ? qrid : 'NULL::integer'},#{!lookup_table_value.blank? && lookup_table_value.respond_to?(:to_f) ? _lookup_table_value : 'NULL::integer'}, '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}')"
    end

    return {
      sql: s,
      unsaved_daur: DecisionAidUserResponse.new(number_response_value: _nrv, question_response_id: qrid, lookup_table_value: _lookup_table_value, question_id: self.id, decision_aid_user_id: decision_aid_user_id)
    }
  end

  def generate_executable_string(rs)
    return "" if self.response_value_calculation.nil?

    s = self.response_value_calculation.gsub( /\[question_([0-9]+)(_numeric)?(_json_key='(.*?)')?\]/).each do |match|
      id = /[0-9]+/.match(match).to_s.to_i
      numeric = numeric = match[/numeric/, 0]
      json_key = match[/json_key='(.*?)'/, 1]
      if rs[id]
        if rs[id].is_a?(Hash) and json_key
          rs[id][json_key]
        else
          rs[id]
        end
      else
        ""
      end
    end

    # replace ceil, floor, min and max with functions
    s = s.gsub(/ceil|floor|min|max/).each do |match|
      if match.to_s == "floor"
        "MathService.floor"
      elsif match.to_s == "ceil"
        "MathService.ceil"
      elsif match.to_s == "max"
        "MathService.max"
      elsif match.to_s == "min"
        "MathService.min"
      else
        match
      end
    end

    # remove all spaces
    s = s.gsub(/\s+/, "")

    s
  end

  def find_question_ids
    #puts "FINDING QUESTION IDS"
    #puts self.response_value_calculation
    return [] if self.response_value_calculation.nil?
    question_ids = []
    #puts "\nSCANNING\n"
    self.response_value_calculation.scan( /\[question_([0-9]+)(_numeric)?(_json_key='(.*?)')?+\]/).each do |match|
      #puts match.inspect
      id = match[0].to_s.to_i
      #puts "\n\n\n"
      #puts id
      question_ids.push(id)
    end
    question_ids.uniq
  end

  # def calculate_hidden_value(decision_aid_user, daurid=nil, responses=nil)
  #   case self.question_response_type
  #   when "radio", "number", "yes_no"
  #     calculate_radio_or_numeric_hidden_value(decision_aid_user, daurid, responses)
  #   when "lookup_table"
  #     calculate_lookup_table_hidden_value(decision_aid_user, daurid)
  #   else
  #     nil
  #   end
  # end

  def validate_response_type
    if question_response_type != "radio" and question_response_type != "yes_no"
      errors.add(:question_response_type, "in grid questions must be radio or yes_no")
    end
  end

  def validate_grid_questions
    if grid_questions.reject(&:marked_for_destruction?).length == 0
      errors.add(:grid_questions, "must have at least one question in a grid")
    end
  end

  def validate_responses_length
    if question_responses.reject(&:marked_for_destruction?).length == 0
      errors.add(:question_responses, "must have at least one response")
    end
  end

  def validate_hidden_question
    if question_response_type != "radio" && 
       question_response_type != "number" && 
       question_response_type != 'lookup_table' && 
       question_response_type != "yes_no" && 
       question_response_type != "json" &&
       question_response_type != "text"
      errors.add(:hidden, "can only be applied to radio, yes/no, number, and lookup table questions")
    end
  end

  def validate_non_hidden_question
    if question_response_type == "lookup_table"
      errors.add(:hidden, "cannot have non-hidden lookup table questions")
    end
  end

  def validate_lookup_table_dimensions
    if lookup_table_dimensions.length != lookup_table_dimensions.uniq.length
      errors.add(:lookup_table_dimensions, "cannot have two dimensions that are the same")
    end
  end

  def validate_yes_no_responses_length
    if question_responses.reject(&:marked_for_destruction?).length != 2
      errors.add(:yes_no_questions, "must have exactly 2 responses")
    end
  end

  def validate_current_treatment_length
    if self.new_record? && Question.where(decision_aid_id: self.decision_aid_id, sub_decision_id: self.sub_decision_id, question_response_type: Question.question_response_types[:current_treatment]).count >= 1
      errors.add(:decision_aid, "can only have one Current Treatment question per sub decision")
    end
  end

  def validate_units_array
    if self.units_array && self.units_array.any?{|unit| unit.blank? }
      errors.add(:question, "unit of measurement value cannot be blank")
    end
  end

  def validate_slider_question
    if !self.min_number
      errors.add(:min_number, "must be set")
    end
    if !self.max_number
      errors.add(:max_number, "must be set")
    end
    if !self.slider_granularity
      errors.add(:step_size, "must be set")
    end
    if !self.min_chars
      errors.add(:start_position, "must be set")
    end

    if self.min_number and self.max_number and self.slider_granularity and self.min_chars
      if self.min_number >= self.max_number
        errors.add(:min_number, "must be less than max number")
      end

      if !self.slider_granularity.between?(self.min_number, self.max_number)
        errors.add(:step_size, "must be between min and max number")
      end

      if !self.min_chars.between?(self.min_number, self.max_number)
        errors.add(:start_position, "must be between min and max number")
      end
    end
  end

  def validate_sum_to_n
    if !self.max_number or self.max_number <= 0
      errors.add(:max_number, "must be set to a value > 0")
    end
  end

  def validate_remote_data_source_and_target
    if self.remote_data_source and self.remote_data_target
      errors.add(:remote_data_source, "can't be set when remote_data_target is also set")
    end
  end

  def validate_question_response_style
    valid_types = []

    case self.question_response_type
    when "radio"
      valid_types = ["horizontal_radio", "vertical_radio", "dropdown_radio"]
    when "yes_no"
      valid_types = ["normal_yes_no"]
    when "text"
      valid_types = ["normal_text"]
    when "grid"
      valid_types = ["normal_grid"]
    when "number"
      valid_types = ["normal_number"]
    when "lookup_table"
      valid_types = ["normal_lookup_table"]
    when "current_treatment"
      valid_types = ["normal_current_treatment"]
    when "json"
      valid_types = ["normal_json"]
    when "heading"
      valid_types = ["normal_heading"]
    when "slider"
      valid_types = ["horizontal_slider", "vertical_slider"]
    when "ranking"
      valid_types = ["normal_ranking"]
    when "sum_to_n"
      valid_types = ["horizontal_sum_to_n", "vertical_sum_to_n", "stacking_sum_to_n"]
    else
      valid_types = []
    end

    if !valid_types.include?(self.question_response_style)
      errors.add(:question_response_style, "invalid for #{self.question_response_type} response type")
    end
  end

  def question_page_valid
    if self.hidden
      if self.question_page_id
        errors.add(:question_page, "hidden questions cannot be on a question page")
      end
    else

      if !self.question and !self.question_page_id
        errors.add(:question_page, "must be defined")
      elsif self.question and self.question_page_id
        errors.add(:question_page, "must not be defined for grid questions")
      end

      if !self.question and self.question_page_id
        qp = QuestionPage.find_by(id: self.question_page_id)
        errors.add(:question_page, "must be a valid question page") if !qp
        if (qp.section == "about" and self.question_type != "demographic") or
           (qp.section == "quiz" and self.question_type != "quiz")

          errors.add(:question_page, "page section must match question type")         
        end
      end
    end
  end

  def duplicate_responses(q, cloned_question)
    q.question_responses.each do |qr|
      qr_dup = qr.dup
      qr_dup.question_id = cloned_question.id
      qr_dup.save!
    end
  end

  def duplicate_grid_questions(question_atts, cloned_question)
    grid_questions.each_with_index do |q, i|
      cloned_grid_question = q.dup
      cloned_grid_question.question_type = question_atts[:question_type]
      cloned_grid_question.question_id = cloned_question.id
      cloned_grid_question.question_order = i + 1
      cloned_grid_question.skip_validate_responses_length = true
      cloned_grid_question.save!
      duplicate_responses(q, cloned_grid_question)
    end
  end

  def delete_responses
    self.question_responses.destroy_all
  end

  def delete_grid_questions
    self.grid_questions.destroy_all
  end

  def update_order_after_destroy
    question_id.nil?
  end

  def update_decision_aid_users_create
    if question_id.blank? and !self.hidden
      if self.question_type == "demographic"
        demo_count = Question.where(decision_aid_id: decision_aid_id, question_id: nil, question_type: Question.question_types[:demographic]).count
        if demo_count == 1
          ProgressTrackerWorker.perform_async(self.decision_aid_id, "demo_create")
        end
      elsif self.question_type == "quiz"
        quiz_count = Question.where(decision_aid_id: decision_aid_id, question_id: nil, question_type: Question.question_types[:quiz]).count
        #puts "\n\n\n#{quiz_count.to_s}\n\n\n"
        if quiz_count == 1
          ProgressTrackerWorker.perform_async(self.decision_aid_id, "quiz_create")
        end
      end
    end
  end

  def update_decision_aid_users_destroy
    # these should happen in background processes
    # puts "\n\n\n#{self.decision_aid.quiz_questions_count}\n\n\n"
    if question_id.blank? and !self.hidden
      if self.question_type == "demographic"
        demo_count = Question.where(decision_aid_id: decision_aid_id, question_id: nil, question_type: Question.question_types[:demographic]).count
        if demo_count == 0
          ProgressTrackerWorker.perform_async(self.decision_aid_id, "demo_destroy")
        end
      elsif self.question_type == "quiz"
        quiz_count = Question.where(decision_aid_id: decision_aid_id, question_id: nil, question_type: Question.question_types[:quiz]).count
        #puts "\n\n\n#{quiz_count.to_s}\n\n\n"
        if quiz_count == 0
          ProgressTrackerWorker.perform_async(self.decision_aid_id, "quiz_destroy")
        end
      end
    end
  end

  def update_question_order
    self.hidden = !self.hidden
    self.remove_from_order
    self.hidden = !self.hidden
    self.initialize_order(self.order_scope.count)
  end
end
