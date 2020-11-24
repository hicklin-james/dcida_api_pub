class DecisionAidHomeIntroSerializer < DecisionAidHomeSerializer

  attributes :injected_intro_popup_information_published,
    :has_intro_popup,
    :intro_page,
    :intro_pages_count,
    :begin_button_text

  # def injected_description_published
  #   object.injected_description_published(instance_options[:decision_aid_user])
  # end

  def injected_intro_popup_information_published
    object.injected_intro_popup_information_published(instance_options[:decision_aid_user])
  end

  def intro_page
    if instance_options[:intro_page]
      s = DecisionAidHomeIntroPageSerializer.new(instance_options[:intro_page], decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    else
      nil
    end
  end

  # def intro_pages
  #   ps = object.intro_pages.ordered
  #   ps.map do |p| 
  #     s = DecisionAidHomeIntroPageSerializer.new(p, decision_aid_user: instance_options[:decision_aid_user])
  #     adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
  #     adapter.as_json
  #   end
  # end

end