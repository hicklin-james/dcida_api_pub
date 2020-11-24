module Api
  ##
  # The {DecisionAidHomeController} class is the main front end controller esponsible for rendering 
  # the basic JSON needed for each page. It doesn't include {DecisionAidUser} children, but it does
  # include the current {DecisionAidUser}.
  #
  # The current user's session is validated before each action, and the available links with respect
  # to the navbar are calculated. The {DecisionAid} is found based on the `slug` param which must be
  # present in all requests. All requests also expect a header with key `DECISION-AID-USER-ID`,
  # in order to identify the current {DecisionAidUser}.
  #
  class DecisionAidHomeController < ApplicationController
    before_action :find_decision_aid
    before_action :find_decision_aid_user, except: [:get_decision_aid_user, :get_language]
    before_action :create_or_find_decision_aid_user, only: [:get_decision_aid_user]
    before_action :get_decision_aid_user_pages,  except: [:generate_pdf, :open_pdf, :get_language]
    #before_action :find_decision_aid_user
    #before_action :calculate_links

    def get_decision_aid_user
      render json: @decision_aid_user,
        serializer: DecisionAidHomeDecisionAidUserSerializer,
        meta: {
          pages: @pages,
          is_new_user: @is_new_user
        }, status: 200
    end

    def get_language
      render json: {lang: @decision_aid.language_code}
    end

    def static_page
      static_pages  = StaticPage.where(decision_aid_id: @decision_aid.id, page_slug: params[:static_page_slug])
      static_page = nil
      if static_pages.count == 1
        static_page = static_pages.first
      end

      render json: @decision_aid,
        serializer: DecisionAidHomeStaticPageSerializer,
        decision_aid_user: @decision_aid_user,
        static_page: static_page,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def intro
      cip = nil
      if params[:first] and params[:first] == "true"
        cip = @decision_aid.intro_pages.ordered.first
      elsif params[:back] and params[:back] == "true"
        cip = @decision_aid.intro_pages.ordered.last
      elsif params[:curr_intro_page_order]
        cip = @decision_aid.intro_pages.find_by(intro_page_order: params[:curr_intro_page_order])
      end


      render json: @decision_aid, 
        serializer: DecisionAidHomeIntroSerializer,
        decision_aid_user: @decision_aid_user,
        intro_page: cip,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def about
      cp = nil
      if params[:first] and params[:first] == "true"
        cp = @decision_aid.demographic_question_pages.ordered.first
      elsif params[:back] and params[:back] == "true"
        cp = @decision_aid_user.find_prev_question_page(params[:curr_question_page_id], 'about')
      elsif params[:curr_question_page_id]
        cp = QuestionPage.find(params[:curr_question_page_id])
      end

      if cp and cp.decision_aid_id != @decision_aid.id
        cp = nil
      end

      render json: @decision_aid, 
        serializer: DecisionAidHomeAboutSerializer,
        decision_aid_user: @decision_aid_user,
        decision_aid: @decision_aid,
        question_page: cp,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def options
      sub_decision_order = if params[:sub_decision_order] and params[:sub_decision_order].to_i > 0 then params[:sub_decision_order].to_i else 1 end
      sub_decision_order = 1 if sub_decision_order > @decision_aid.sub_decisions.count
      sub_decision = SubDecision.find_by(decision_aid_id: @decision_aid.id, sub_decision_order: sub_decision_order)
      render json: @decision_aid,
        serializer: DecisionAidHomeOptionsSerializer,
        decision_aid_user: @decision_aid_user,
        sub_decision: sub_decision,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def properties

      render json: @decision_aid,
        serializer: DecisionAidHomePropertiesSerializer,
        decision_aid_user: @decision_aid_user,
        decision_aid: @decision_aid,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def properties_enhanced

      render json: @decision_aid,
        serializer: DecisionAidHomePropertiesSerializer,
        decision_aid_user: @decision_aid_user,
        decision_aid: @decision_aid,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def properties_decide

      render json: @decision_aid,
        serializer: DecisionAidHomePropertiesSerializer,
        decision_aid_user: @decision_aid_user,
        decision_aid: @decision_aid,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def properties_post_best_worst

      render json: @decision_aid,
        serializer: DecisionAidHomePropertiesSerializer,
        decision_aid_user: @decision_aid_user,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def traditional_properties
      render json: @decision_aid,
        serializer: DecisionAidHomeTraditionalPropertiesSerializer,
        decision_aid_user: @decision_aid_user,
        options: @decision_aid.relevant_options(@decision_aid_user, nil, nil).includes(:media_file),
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def best_worst
      if !@decision_aid_user.randomized_block_number
        max = BwQuestionSetResponse.where(decision_aid_id: @decision_aid.id).maximum(:block_number)
        max ||= 1
        curr = @decision_aid.current_block_number
        if curr < max
          @decision_aid.update_attribute(:current_block_number, curr + 1)
          @decision_aid_user.update_attribute(:randomized_block_number, curr + 1)
        else
          @decision_aid.update_attribute(:current_block_number, 1)
          @decision_aid_user.update_attribute(:randomized_block_number, 1)
        end
      end

      render json: @decision_aid,
        serializer: DecisionAidHomeBestWorstSerializer,
        decision_aid_user: @decision_aid_user,
        current_question_set: (params[:current_question_set].to_i if params.has_key?(:current_question_set)),
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def dce
      # TODO Move out of controller
      if !@decision_aid_user.randomized_block_number
        max = DceQuestionSetResponse.where(decision_aid_id: @decision_aid.id).maximum(:block_number)
        max ||= 1
        curr = @decision_aid.current_block_number
        if curr < max
          @decision_aid.update_attribute(:current_block_number, curr + 1)
          @decision_aid_user.update_attribute(:randomized_block_number, curr + 1)
        else
          @decision_aid.update_attribute(:current_block_number, 1)
          @decision_aid_user.update_attribute(:randomized_block_number, 1)
        end
      end

      render json: @decision_aid,
        serializer: DecisionAidHomeDceSerializer,
        decision_aid_user: @decision_aid_user,
        current_question_set: (params[:current_question_set].to_i if params.has_key?(:current_question_set)),
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def results
      sub_decision_order = if params[:sub_decision_order] and params[:sub_decision_order].to_i > 0 then params[:sub_decision_order].to_i else 1 end
      sub_decision_order = 1 if sub_decision_order > @decision_aid.sub_decisions.count
      sub_decision = SubDecision.find_by(decision_aid_id: @decision_aid.id, sub_decision_order: sub_decision_order)
      
      result_match_option = nil
      if @decision_aid.decision_aid_type == 'dce'
        result_match_option = @decision_aid.option_match_from_dce(@decision_aid_user)
      elsif @decision_aid.decision_aid_type == 'best_worst' or @decision_aid.decision_aid_type == 'best_worst_with_prefs_after_choice'
        result_match_option = @decision_aid.option_match_from_best_worst(@decision_aid_user, sub_decision.id)
      elsif @decision_aid.decision_aid_type == "standard_enhanced" or @decision_aid.decision_aid_type == "treatment_rankings"
        result_match_option = @decision_aid.option_match_from_standard(@decision_aid_user, sub_decision.sub_decision_order)
      end

      # some results return all options, so filter by relevant options so that frontend handles properly
      relevant_options = @decision_aid.relevant_options(@decision_aid_user, nil, sub_decision.id).includes(:media_file)
      if result_match_option and relevant_options
        result_match_option = result_match_option.select {|k,v| relevant_options.map(&:id).include?(k) }
      end

      render json: @decision_aid,
        serializer: DecisionAidHomeResultsSerializer,
        decision_aid_user: @decision_aid_user,
        result_match_option: result_match_option,
        sub_decision: sub_decision,
        options: relevant_options,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user,
          result_match_option: result_match_option,
          sub_decision_id: sub_decision.id
        }
    end

    def quiz
      cp = nil
      if params[:first] and params[:first] == "true"
        cp = @decision_aid.quiz_question_pages.ordered.first
      elsif params[:back] and params[:back] == "true"
        cp = @decision_aid_user.find_prev_question_page(params[:curr_question_page_id], 'quiz')
      elsif params[:curr_question_page_id]
        cp = QuestionPage.find(params[:curr_question_page_id])
      end

      if cp and cp.decision_aid_id != @decision_aid.id
        cp = nil
      end

      render json: @decision_aid, 
        serializer: DecisionAidHomeQuizSerializer,
        decision_aid_user: @decision_aid_user,
        decision_aid: @decision_aid,
        question_page: cp,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user
        }
    end

    def summary

      @decision_aid_user.parse_and_set_user_agent(request.user_agent)
      @decision_aid_user.save!

      sdids = @decision_aid.sub_decisions.pluck(:id)
      result_match_option = nil

      options = @decision_aid.relevant_options(@decision_aid_user, nil, nil)
        .joins(:sub_decision)
        .includes(:media_file)
        .select("sub_decisions.sub_decision_order as sub_decision_order, options.*")

      sdids.each do |sdid|
        inner_match = nil
        if @decision_aid.decision_aid_type == 'dce'
          inner_match = @decision_aid.option_match_from_dce(@decision_aid_user)
        elsif @decision_aid.decision_aid_type == 'best_worst'
          inner_match = @decision_aid.option_match_from_best_worst(@decision_aid_user, sdid)
        end
        if inner_match
          result_match_option = {} if result_match_option.nil?
          result_match_option = result_match_option.merge inner_match
        end
      end
      
      if @decision_aid.decision_aid_type == "best_worst_no_results"
        @decision_aid.option_match_from_best_worst(@decision_aid_user, nil)
      end

      @decision_aid_user.update_attribute(:estimated_end_time, Time.now)
      @decision_aid_user.do_async_summary_page_work
      #@decision_aid_user.trigger_summary_page_emails
      #@decision_aid_user.populate_remote_data_targets_with_summary

      render json: @decision_aid,
        serializer: DecisionAidHomeSummarySerializer,
        decision_aid_user: @decision_aid_user,
        options: options,
        meta: {
          pages: @pages,
          decision_aid_user: @decision_aid_user,
          is_new_user: @is_new_user,
          result_match_option: result_match_option
        }
    end

    ##
    # Stubbed
    #
    def mail_summary_to_user
      if params.has_key?(:email) and !params[:email].blank?
        puts "sup"
        # send email to user
      else
        render json: {errors: ["InvalidEmail"]}, status: 400
      end
    end

    def generate_pdf
      require 'open-uri'
      html = params[:html]
      if !html.blank? 
        stylesheet_link = RequestStore.store[:origin] + "/styles/main_dist.css"
        html = html.prepend("<link rel='stylesheet' href='#{stylesheet_link}'>")
        html = html.prepend('<style>body {font-size: 12pt;} table {font-size: 12pt;} tr {page-break-inside: avoid;}</style>')
        html = html.prepend("<style>#{@decision_aid.custom_css}</style>")
        primary_param = @decision_aid_user.decision_aid_user_query_parameters
            .joins(:decision_aid_query_parameter)
            .where("decision_aid_query_parameters.is_primary = ?", true)
            .select("decision_aid_user_query_parameters.*, decision_aid_query_parameters.input_name as input_name").take

        #puts primary_param.inspect
        if !params[:omit_pid] and primary_param and primary_param.param_value
          html.prepend('<div class="text-right"><p>' + primary_param.input_name + ': ' + primary_param.param_value.to_s + "</p><p>Completed on: #{Time.now.strftime("%B %-d, %Y at %I:%M %
            ")}</p></div>")
        else
          html.prepend('<div class="text-right">' + "Completed on: #{Time.now.strftime("%B %-d, %Y at %I:%M %p")}</p></div>")   
        end

        parsed_html = Nokogiri::HTML(html)
        parsed_html.css("body").first["style"] = "width: 1140px;"

        DecisionAidMailWorker.perform_async(@decision_aid.id, @decision_aid_user.id, parsed_html.to_s, params[:send_address])
        # DecisionAidMailer.summary_mail(@decision_aid.id, @decision_aid_user.id, html).deliver_later
      end
      render json: { message: "removed" }, status: :ok
    end

    def open_pdf
      require 'open-uri'
      html = params[:html]
      if !html.blank? 
        stylesheet_link = RequestStore.store[:origin] + "/styles/main_dist.css"
        html = html.prepend("<link rel='stylesheet' href='#{stylesheet_link}'>")
        html = html.prepend('<style>body {font-size: 12pt;} table {font-size: 12pt;} tr {page-break-inside: avoid;}</style>')
        html = html.prepend("<style>#{@decision_aid.custom_css}</style>")
        
        primary_param = @decision_aid_user.decision_aid_user_query_parameters
          .joins(:decision_aid_query_parameter)
          .where("decision_aid_query_parameters.is_primary = ?", true)
          .select("decision_aid_user_query_parameters.*, decision_aid_query_parameters.input_name as input_name").take
        
        if !params[:omit_pid] and primary_param and primary_param.param_value
          html.prepend('<div class="text-right"><p>' + primary_param.input_name + ': ' + primary_param.param_value + "</p><p>Completed on: #{Time.now.strftime("%B %-d, %Y at %I:%M %p")}</p></div>")
        else
          html.prepend('<div class="text-right">' + "Completed on: #{Time.now.strftime("%B %-d, %Y at %I:%M %p")}</p></div>")   
        end
        parsed_html = Nokogiri::HTML(html)
        parsed_html.css("body").first["style"] = "width: 1140px;"

        kit = PDFKit.new(parsed_html.to_s, :page_size => 'Letter', :viewport_size => "1140x1477")
        download_item = DownloadItem.create(download_type: "patient_pdf_download")
        download_item.make_pdf(kit, @decision_aid_user)
        render json: download_item
        # pdf = kit.to_pdf
        # save the PDF somewhere temporary that only the patient can access
      else
        render json: download_item, status: 422 
      end
    end

    private

    def pundit_user
      current_decision_aid_user
    end

    def create_or_find_decision_aid_user
      render(json: { error: 'PasswordProtected'}, status: :forbidden) and return if (@decision_aid.password_protected and (params[:decision_aid_password] != @decision_aid.access_password))
      # get decision aid query params

      eps = ( params[:query_params] ? JSON.parse(params[:query_params]) : nil )
      user_info = DecisionAidUser.find_or_create_decision_aid_user(@decision_aid, request.headers["DECISION-AID-USER-ID"], eps, request.user_agent)

      if user_info.has_key?(:user)
        @decision_aid_user, @is_new_user = user_info[:user], user_info[:new_user]
        DecisionAidUserSession.create_or_update_user_session(@decision_aid_user.id)
      else
        render json: {errors: user_info[:user_error].errors}, status: 400
      end
    end

    def find_decision_aid
      decision_aid_query = get_query_based_on_action
      if decision_aid_query.length > 0
        @decision_aid = decision_aid_query.first
      else
        render json: {errors: "DecisionAidNotFound"}, status: 404
      end
    end

    def get_query_based_on_action
      query = DecisionAid.where(slug: params[:slug])
      case action_name
      when "results"
        query = query.includes(:options, :option_properties, :properties => [:property_levels])
      when "best_worst"
        query = query.includes(:properties => [:property_levels])
      end
      query
    end

    def get_decision_aid_user_pages
      progress_tracker = @decision_aid_user.progress_tracker
      @pages = progress_tracker.calculate_progress(@decision_aid)
      if action_name != 'get_decision_aid_user' and action_name != 'mail_summary_to_user' and action_name != 'static_page'
        key = nil
        if action_name == "results"
          key = "results_#{params[:sub_decision_order]}"
        else
          key = action_name
        end
        
        session_invalid("page_restricted") if !@pages[key.to_sym] || !@pages[key.to_sym][:available]
      end
    end

    def find_decision_aid_user
      user = current_decision_aid_user
      @decision_aid_user = user
      @is_new_user = false
    end
  end
end