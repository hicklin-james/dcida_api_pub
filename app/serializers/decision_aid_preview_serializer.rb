class DecisionAidPreviewSerializer < ActiveModel::Serializer

  attributes :about_information_published,
    :options_information_published,
    :description_published,
    :properties_information_published,
    :property_weight_information_published,
    :minimum_property_count,
    :maximum_property_count,
    :chart_type,
    :ratings_enabled, 
    :percentages_enabled, 
    :best_match_enabled,
    :decision_aid_type,
    :results_information_published,
    :quiz_information_published,
    :final_summary_text_published,
    :more_information_button_text,
    :dce_information_published,
    :dce_specific_information_published,
    :opt_out_label,
    :best_worst_information_published,
    :best_worst_specific_information_published,
    :bw_question_set_responses_count,
    :best_wording,
    :worst_wording
    #:intro_pages

    # def intro_pages
    #   ps = object.intro_pages.ordered
    #   ps.map do |p| 
    #     s = DecisionAidHomeIntroPageSerializer.new(p, decision_aid_user: nil)
    #     adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
    #     adapter.as_json
    #   end
    # end

    
end