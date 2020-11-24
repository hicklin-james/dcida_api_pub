class MySqlImportService

  def initialize(decision_aid)
    @decision_aid = decision_aid
    dbname = decision_aid.mysql_dbname
    username = decision_aid.mysql_user
    password = decision_aid.mysql_password
    # connect to mysql database
    begin
      @conn = Mysql2::Client.new(:host => "localhost", :username => username, password: password, database: dbname)
    rescue
      @conn = nil
    end
  end

  def test_connection
    
    # @params[:content] = "version"
    # r = make_request()
    # return r if (r.class == Hash and r.has_key?(:error))
    # if r.body.to_i != 0
    #   {body: r.body}
    # else
    #   {error: r.body}
    # end

    # @params[:content] = "metadata"
    # @params[:format] = "json"
    # @params["fields[]"] = ["gender"]
    # r = make_request()
    # puts r.body
    # {body: r.body}
  end 

  def import(questions, decision_aid_user)
    return if questions.empty? or @conn.nil?
    responses = get_relevant_responses(questions, decision_aid_user)
    saved_question_ids = []
    insert_sql = questions.map { |q|
      params = q.generate_mysql_params(decision_aid_user, responses)
      # break out if a param was missing
      return [] if params.nil?
      #puts params.inspect
      puts "\n\n\nCalling: #{q.my_sql_procedure_name}(#{params})\n\n\n"
      r = @conn.query("CALL #{q.my_sql_procedure_name}(#{params})")
      vals = nil
      #puts r.inspect
      if r
        data = r.first
        vals = "(#{decision_aid_user.id},#{q.id},'#{data.to_json}','#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}')"
        saved_question_ids.push q.id
      end
      @conn.abandon_results!
      vals
    }.compact.join(",")
    if !insert_sql.blank?
      ActiveRecord::Base.connection.execute("INSERT INTO decision_aid_user_responses (decision_aid_user_id, question_id, json_response_value, created_at, updated_at) VALUES #{insert_sql}")
    end
    saved_question_ids
  end

  private

  def get_relevant_responses(mysql_questions, decision_aid_user)
    related_question_ids = mysql_questions.map{|q| 
      q.my_sql_question_params.map{|p|
        match = /\[question_([0-9]+)( numeric)?\]/.match(p.value)
        if match
          question_id = match[1]
        end
      }
    }.flatten.compact.uniq
    DecisionAidUserResponse.where(question_id: related_question_ids, decision_aid_user_id: decision_aid_user.id)
      .joins("LEFT OUTER JOIN question_responses ON question_responses.id = decision_aid_user_responses.question_response_id")
      .joins("LEFT OUTER JOIN questions on questions.id = decision_aid_user_responses.question_id")
      .select("decision_aid_user_responses.*, question_responses.numeric_value as numeric_response_value, question_responses.question_response_value as question_response_value", "questions.question_response_type as question_response_type")
      .index_by(&:question_id)
  end
end