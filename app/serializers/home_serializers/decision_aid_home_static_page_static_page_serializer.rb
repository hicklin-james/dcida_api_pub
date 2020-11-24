class DecisionAidHomeStaticPageStaticPageSerializer < ActiveModel::Serializer

  attributes :page_title,
    :injected_page_text_published,
    :page_slug

  def injected_page_text_published
    object.injected_page_text_published(instance_options[:decision_aid_user])
  end

end