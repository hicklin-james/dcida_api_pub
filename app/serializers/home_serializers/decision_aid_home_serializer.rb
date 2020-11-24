class DecisionAidHomeSerializer < ActiveModel::Serializer

  attributes :id,
    :title,
    :slug,
    :demographic_questions_count,
    :quiz_questions_count,
    :decision_aid_type,
    :icon_image,
    :footer_logos_with_urls,
    :navigation_links,
    :theme,
    :contact_email,
    :contact_phone_number,
    :description,
    :hide_menu_bar,
    :language_code,
    :full_width,
    :custom_css

end