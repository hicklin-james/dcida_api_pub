module Api
  ##
  # Main controller for {Option options} with respect to their management (ie. backend)
  #
  # All actions in this controller undergo a call to `doorkeeper_authorize`, `authenticate` and
  # `find_decision_aid`. Ensure that requests have valid tokens and that the logged in user has
  # permission to make the request, otherwise the responses will be HTTP errors. For action specific
  # authorization, see {OptionPolicy}. Note that on successful requests, all actions will return a 200
  # response code.
  #
  class OptionsController < ApplicationController
    before_action :doorkeeper_authorize!
    before_action :authenticate!
    before_action :find_decision_aid

    ##
    # {Option} #show action. This is action is used to get an {Option}.
    #
    # GET /api/decision_aids/{ decision_aid_id }/options/{ id }
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  id: an Option id
    #
    # returns:
    #  Option
    # 
    # == Response Example
    # 
    #  option:
    #    id: 1
    #    title: "Advil"
    #    option_order: 1
    #    ...
    # 
    def show
      option = Option.includes(:media_file).find(params[:id])
      authorize option
      render json: option, serializer: OptionShowSerializer
    end

    ##
    # {Option} #index action. This is action is used to get a list of {Option options}
    #
    # GET /api/decision_aids/{ decision_aid_id }/options
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #
    # returns:
    #  [Option]
    # 
    # == Response Example
    # 
    #  options:
    #    id: 1
    #    title: "Advil"
    #    option_order: 1
    #   ,
    #    id: 2
    #    title: "Tylenol"
    #    option_order: 2
    # 
    def index
      options = OptionPolicy::Scope.new(current_user, Option, @decision_aid).resolve.includes(:sub_options).ordered
      if params.has_key?(:sub_decision_id) and params[:sub_decision_id]
        options = options.where(sub_decision_id: params[:sub_decision_id])
      end
      render json: options
    end

    ##
    # {Option} #create action. This is action is used to create an {Option}.
    #
    # POST /api/decision_aids/{ decision_aid_id }/options
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  option: an object representing an Option
    #   e.g.
    #    option:
    #     title: "Advil"
    #     label: "Advil label"
    #     description: "Advil information" 
    #
    # returns:
    #  Option
    # 
    # == Response Example
    # 
    #  option:
    #    id: 1
    #    title: "Advil"
    #    label: "Advil label"
    #    description: "Advil information"
    #    ...
    # 
    def create
      option = Option.new(option_params)
      option.decision_aid = @decision_aid
      authorize option

      if option.save
        render json: option, serializer: OptionShowSerializer
      else
        render json: { errors: option.errors.full_messages }, status: 422
      end

    end

    ##
    # {Option} #update action. This is action is used to update an {Option}.
    #
    # PUT /api/decision_aids/{ decision_aid_id }/options/{ id }
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  id: an Option id
    #  option: an object representing an Option
    #   e.g.
    #    option:
    #     title: "New title"
    #
    # returns:
    #  Option
    # 
    # == Response Example
    # 
    #  option:
    #    id: 1
    #    title: "New title"
    #    label: "Advil label"
    #    description: "Advil information"
    #    ...
    # 
    def update
      option = Option.find(params[:id])
      authorize option

      if option.update(option_params)
        render json: option, serializer: OptionShowSerializer
      else
        render json: { errors: option.errors.full_messages }, status: 422
      end
      
    end

    ##
    # {Option} #destroy action. This is action is used to delete an {Option}.
    #
    # DELETE /api/decision_aids/{ decision_aid_id }/options/{ id }
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  id: an Option id
    #
    # returns:
    #  nothing    # 
    def destroy
      option = Option.find(params[:id])
      authorize option

      if option.destroy
        render json: { message: "removed" }, status: :ok
      else
        render json: { errors: option.errors.full_messages }, status: 422
      end
    end

    ##
    # {Option} #clone action. This action clones an {Option}.
    #
    # POST /api/decision_aids/{ decision_aid_id }/options/{ id }/clone
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  id: an Option id
    #
    # returns:
    #  Option
    # 
    # == Response Example
    # 
    #  option:
    #    id: 2
    #    title: "Advil"
    #    option_order: 2
    #    ...
    # 
    def clone
      option = Option.find(params[:id])
      authorize option

      r = option.clone_option(@decision_aid)
      if r.has_key?(:option)
        render json: r[:option]
      else
        render json: r[:errors], status: 422
      end
    end

    ##
    # {Option} #preview action. This action will return the published fields of the {Option}.
    # See {OptionPreviewSerializer} for more information.
    #
    # GET /api/decision_aids/{ decision_aid_id }/options/{ id }/preview
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  id: an Option id
    #
    # returns:
    #  [Option]
    # 
    # == Response Example
    # 
    #  options:
    #    id: 1
    #    title: "Advil"
    #    option_order: 1
    #   ,
    #    id: 2
    #    title: "Tylenol"
    #    option_order: 2
    # 
    def preview
      options = OptionPolicy::Scope.new(current_user, Option, @decision_aid).resolve.includes(:media_file).ordered
      render json: options, each_serializer: OptionPreviewSerializer
    end

    ##
    # {Option} #update_order action. This action updates the order of an {Option}.
    #
    # POST /api/decision_aids/{ decision_aid_id }/options/{ id }/update_order
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  id: an Option id
    #
    # returns:
    #  Option
    # 
    # == Response Example
    # 
    #  option:
    #    id: 2
    #    title: "Advil"
    #    option_order: 2
    #    ...
    # 
    def update_order
      option = Option.find(params[:id])
      authorize option

      option.change_order(option_params[:option_order])
      render json: option
    end

    ##
    # {Option} #options_from_last_sub_decision action.
    #
    # GET /api/decision_aids/{ decision_aid_id }/options/options_from_last_sub_decision
    # 
    # params:
    #  decision_aid_id: a DecisionAid id
    #  sub_decision_order: optional sub_decision_order
    #
    # returns:
    #  [Option]
    # 
    # == Response Example
    # 
    #  options:
    #    id: 1
    #    title: "Advil"
    #    option_order: 1
    #   ,
    #    id: 2
    #    title: "Tylenol"
    #    option_order: 2
    # 
    def options_from_last_sub_decision
      options = OptionPolicy::Scope.new(current_user, Option, @decision_aid).resolve.includes(:sub_options, :media_file).ordered
      if params.has_key?(:sub_decision_order) and params[:sub_decision_order]
        options = options.joins(:sub_decision).where(sub_decisions: {sub_decision_order: params[:sub_decision_order].to_i - 1})
      else
        max_sub_decision_order = SubDecision.where(decision_aid_id: @decision_aid.id).maximum(:sub_decision_order)
        options = options.joins(:sub_decision).where(sub_decisions: {sub_decision_order: max_sub_decision_order})
      end

      render json: options, each_serializer: OptionShowSerializer
    end

    private

    def option_order_params
      params.require(:options).permit(:option_list => [:id, :option_order])
    end

    def option_params
      params[:question_response_array] ||= [] if params.has_key?(:question_response_array)
      params[:sub_options_attributes] ||= [] if params.has_key?(:sub_options_attributes)

      params.require(:option).permit(:title, :option_order, :sub_decision_id, :description, :decision_aid_id, :has_sub_options, :label, :summary_text, :media_file_id, :question_response_array, :generic_name,
                                     :question_response_array => [],
                                     :sub_options_attributes => [:title, :sub_decision_id, :decision_aid_id, :has_sub_options, :option_order, :description, :label, :summary_text, :media_file_id, :question_response_array, :id, :generic_name, :_destroy, :question_response_array => []])
    end

    def find_decision_aid
      @decision_aid = DecisionAid.find params[:decision_aid_id]
    end
  end
end