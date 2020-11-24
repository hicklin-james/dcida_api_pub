class DecisionAidHomeStaticPageSerializer < DecisionAidHomeSerializer

  attributes :static_page

  def static_page
    if instance_options[:static_page]
      s = DecisionAidHomeStaticPageStaticPageSerializer.new(instance_options[:static_page], decision_aid_user: instance_options[:decision_aid_user])
      adapter = ActiveModelSerializers::Adapter::Attributes.new(s)
      adapter.as_json
    else
      nil
    end
  end

end