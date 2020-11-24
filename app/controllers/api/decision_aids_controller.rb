module Api

  ##
  # Main controller for {DecisionAid decision aids} with respect to their management (ie. backend)
  #
  # All actions in this controller undergo a call to `doorkeeper_authorize!` and `authenticate`.
  # Ensure that requests have valid tokens and that the logged in user has permission to make
  # the request, otherwise the responses will be HTTP errors. For action specific authorization,
  # see {DecisionAidPolicy}. Note that on successful requests, all actions will return a 200 response
  # code.
  #
  class DecisionAidsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!

    ##
    # {DecisionAid} #show action. This action is used to get a {DecisionAid}.
    #
    # GET /api/decision_aids/{ id }
    #
    # params:
    #  id - a DecisionAid id
    #
    # returns:
    #  DecisionAid
    #
    # == Response Example
    #
    #  decision_aid: 
    #    id: 4
    #    title: "Knee Pain"
    #    slug: "kneepain"
    #    about_information: "<p>Information</p>"
    #    ...
    #
    def show
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      render json: decision_aid
    end

    def page_targets
      decision_aid = DecisionAid.find(params[:id])
      pages = SectionTracker.pages_for_decision_aid_type(decision_aid.decision_aid_type)
      render json: {pages: pages}
    end

    ##
    # {DecisionAid} #index action. This action is used to get a list of {DecisionAid decision aids}]
    #
    # GET /api/decision_aids
    #
    # returns:
    #  [DecisionAid]
    #
    # == Response Example
    #  decision_aids:
    #    [
    #      id: 4
    #      title: "Knee Pain"
    #      ...
    #     ,
    #       id: 5 
    #       title: "MS"
    #       ...
    #    ]
    #
    def index
      decision_aids = policy_scope(DecisionAid).includes(:creator)
      render json: decision_aids, each_serializer: DecisionAidListSerializer
    end

    ##
    # {DecisionAid} #create action. This action is used to create a {DecisionAid}.
    #
    # POST /api/decision_aids
    #
    # params:
    #  decision_aid - an object representing a {DecisionAid}
    #  e.g.
    #   decision_aid: 
    #     title: "Knee pain"
    #     slug: "kneepain"
    #     decision_aid_type: "standard"
    #    
    #
    # returns:
    #  DecisionAid
    #
    # == Response Example
    #
    #  decision_aid: 
    #    id: 4
    #    title: "Knee pain"
    #    ...
    #
    def create
    	decision_aid = DecisionAid.new(decision_aid_params)
      authorize decision_aid

      if decision_aid.save
        render json: decision_aid
      else
        render json: { errors: decision_aid.errors.full_messages }, status: 422
      end
    end

    ##
    # {DecisionAid} #update action. This action is used to update an existing {DecisionAid}.
    #
    # PUT /api/decision_aids/{ id }
    #
    # params:
    #  id - a DecisionAid id
    #  decision_aid - an object representing the {DecisionAid}
    #   e.g.
    #    decision_aid: 
    #      title: "New title"
    #      slug: "newslug"
    #
    # returns:
    #  DecisionAid
    #
    # == Response Example
    #
    #  decision_aid: 
    #    id: 4
    #    title: "New title"
    #    ...
    #
    def update
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid

      if decision_aid.update(decision_aid_params)
        render json: decision_aid
      else
        render json: { errors: decision_aid.errors.full_messages }, status: 422
      end
    end

    ##
    # {DecisionAid} #destroy action. This action is used to delete a {DecisionAid}.
    #
    # DELETE /api/decision_aids/{ id }
    #
    # params:
    #  id - a DecisionAid id
    #
    # returns:
    #  othing
    
    def destroy
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid

      if decision_aid.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: decision_aid.errors.full_messages }, status: 422
      end
    end

    ##
    # {DecisionAid} #preview action. This action will return the published fields of the 
    # {DecisionAid}. See {DecisionAidPreviewSerializer} for more information.
    #
    # GET /api/decision_aids/{ id }/preview
    #
    # params:
    #  id - a DecisionAid id
    #
    # returns:
    #  DecisionAid
    #
    # == Response Example
    #
    #  decision_aid: 
    #    id: 4
    #    title: "Knee pain"
    #    ...
    def preview
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      render json: decision_aid, serializer: DecisionAidPreviewSerializer
    end

    ##
    # {DecisionAid} #upload_dce_design action. This action is used to upload a new DCE
    # design template.
    #
    # GET /api/decision_aids/{ id }/upload_dce_design
    #
    # params:
    #  id - a DecisionAid id
    #  file - a dce design file (csv only)
    #
    # returns:
    #  DecisionAid
    #
    # == Response Example
    #
    #  decision_aid: 
    #    id: 4
    #    title: "Knee pain"
    #    ...
    def upload_dce_design
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      decision_aid.dce_design_file = params[:file]
      if decision_aid.save
        DceDesignUploadWorker.perform_async(params[:id], current_user.id)
        render json: decision_aid
      else
        render json: { errors: decision_aid.errors.full_messages }, status: 422
      end
    end

    ##
    # {DecisionAid} #upload_dce_results action. This action is used to upload a new DCE
    # results template.
    #
    # GET /api/decision_aids/{ id }/upload_dce_results
    #
    # params:
    #  id - a DecisionAid id
    #  file - a dce results file (csv only)
    #
    # returns:
    #  DecisionAid
    #
    # == Response Example
    #
    #  decision_aid: 
    #    id: 4
    #    title: "Knee pain"
    #    ...
    def upload_dce_results
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      decision_aid.dce_results_file = params[:file]
      if decision_aid.save
        DceResultsUploadWorker.perform_async(params[:id], current_user.id)
        render json: decision_aid
      else
        render json: { errors: decision_aid.errors.full_messages }, status: 422
      end
    end

    ##
    # {DecisionAid} #upload_bw_design action. This action is used to upload a new best-worst
    # design template.
    #
    # GET /api/decision_aids/{ id }/upload_bw_design
    #
    # params:
    #  id - a DecisionAid id
    #  file - a best-worst design file (csv only)
    #
    # returns:
    #  DecisionAid
    #
    # == Response Example
    #
    #  decision_aid: 
    #    id: 4
    #    title: "Knee pain"
    #    ...
    def upload_bw_design
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      decision_aid.bw_design_file = params[:file]
      if decision_aid.save
        BwDesignUploadWorker.perform_async(params[:id], current_user.id)
        render json: decision_aid
      else
        render json: { errors: decision_aid.errors.full_messages }, status: 422
      end
    end

    ##
    # {DecisionAid} #download_user_data action. This action is used to download a decision_aid's user data
    #
    # GET /api/decision_aids/{ id }/download_user_data
    #
    # params:
    #  id - a DecisionAid id
    #
    # returns:
    #  DownloadItem
    #    ...
    def download_user_data
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      di = DownloadItem.create(download_type: "user_data_download")
      #UserDataExport.new(decision_aid, di, current_user.id, params[:export_data]).export
      #CHANGE BACK TO ASYNC
      UserDataExportWorker.perform_async(params[:id], di.id, current_user.id, params[:export_data])
      render json: di, serializer: DownloadItemSerializer  
    end

    def clear_user_data
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      if decision_aid.clear_user_data
        render json: decision_aid
      else
        render json: { errors: ["clearing user data failed"] }, status: 422
      end
    end

    def export
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      di = DownloadItem.create(download_type: "decision_aid_download")
      ExportWorker.perform_async(params[:id], di.id, current_user.id)
      render json: di, serializer: DownloadItemSerializer
    end

    ##
    # {DecisionAid} #setup_dce action. This action is used to generate the dce template
    # files
    #
    # GET /api/decision_aids/{ id }/setup_dce
    #
    # params:
    #  id - a DecisionAid id
    #  num_questions - the number of questions to include in the DCE
    #  num_responses - the number of responses per dce question
    #
    # returns:
    #  DownloadItem
    #
    # == Response Example
    #
    #  download_item: 
    #    id: 1
    #    download_type: "dce_template_download"
    #    processed: false
    #    ...
    def setup_dce
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      di = DownloadItem.create(download_type: "dce_template_download")
      include_opt_out = (params.has_key?(:include_opt_out) && params[:include_opt_out] == "true")
      DceTemplateWorker.perform_async(params[:num_questions], params[:num_responses], params[:num_blocks], include_opt_out, params[:id], di.id, current_user.id)
      render json: di, serializer: DownloadItemSerializer
    end

    ##
    # {DecisionAid} #setup_bw action. This action is used to generate the best-worst template
    # files
    #
    # GET /api/decision_aids/{ id }/setup_bw
    #
    # params:
    #  id - a DecisionAid id
    #  num_questions - the number of questions to include in the DCE
    #  num_attributes_per_question - the number of attributes per best-worst question-set
    #
    # returns:
    #  DownloadItem
    #
    # == Response Example
    #
    #  download_item: 
    #    id: 1
    #    download_type: "bw_template_download"
    #    processed: false
    #    ...
    def setup_bw
      decision_aid = DecisionAid.find(params[:id])
      authorize decision_aid
      di = DownloadItem.create(download_type: "bw_template_download")
      BwTemplateWorker.perform_async(params[:num_questions], params[:num_attributes_per_question], params[:num_blocks], params[:id], di.id, current_user.id)
      render json: di, serializer: DownloadItemSerializer
    end

    def test_redcap_connection
      decision_aid = DecisionAid.find(params[:id])
      # set temp variables to test connection
      decision_aid.redcap_url = params[:redcap_url]
      decision_aid.redcap_token = params[:redcap_token]
      authorize decision_aid
      redcap_service = RedcapService.new(decision_aid)
      r = redcap_service.test_connection
      if r.has_key?(:body)
        render json: {version: r[:body]}, serializer: nil
      else
        render json: {errors: [r[:error]]}, status: 400
      end
    end

    private

    def decision_aid_params
      params[:decision_aid][:footer_logos] ||= [] if params.has_key?(:decision_aid) and params[:decision_aid].has_key?(:footer_logos)
      params[:decision_aid][:summary_email_addresses] ||= [] if params.has_key?(:decision_aid) and params[:decision_aid].has_key?(:summary_email_addresses)

      params.require(:decision_aid).permit(:title, :slug, :description, :about_information, :options_information, 
                                           :properties_information, :results_information, :quiz_information, :worst_wording,
                                           :property_weight_information, :minimum_property_count, :icon_id, :chart_type,
                                           :ratings_enabled, :percentages_enabled, :best_match_enabled, :decision_aid_type,
                                           :dce_information, :dce_specific_information, :other_options_information, :best_wording,
                                           :redcap_url, :redcap_token, :password_protected, :access_password, :theme,
                                           :summary_link_to_url, :best_worst_information, :best_worst_specific_information, 
                                           :intro_popup_information, :has_intro_popup, :include_admin_summary_email, 
                                           :include_user_summary_email, :user_summary_email_text, :mysql_dbname, :mysql_user,
                                           :mysql_password, :contact_phone_number, :contact_email, :include_download_pdf_button,
                                           :final_summary_text, :maximum_property_count, :intro_page_label, :about_me_page_label, 
                                           :properties_page_label, :quiz_page_label, :summary_page_label, :results_page_label,
                                           :opt_out_information, :properties_auto_submit, :opt_out_label, :dce_option_prefix,
                                           :more_information_button_text, :best_worst_page_label, :hide_menu_bar, 
                                           :open_summary_link_in_new_tab, :color_rows_based_on_attribute_levels,
                                           :compare_opt_out_to_last_selected, :use_latent_class_analysis, :language_code,
                                           :full_width, :custom_css, :include_dce_confirmation_question, :dce_confirmation_question,
                                           :dce_type, :begin_button_text, :dce_selection_label, :dce_min_level_color, :dce_max_level_color,
                                           :unique_redcap_record_identifier,
                                           :decision_aid_query_parameters_attributes => [:id, :_destroy, :input_name, :output_name, :is_primary],
                                           :footer_logos => [], :summary_email_addresses => [])
    end
  end
end