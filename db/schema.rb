# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_11_151057) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accordion_contents", id: :serial, force: :cascade do |t|
    t.integer "accordion_id", null: false
    t.string "header"
    t.text "content"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content_published"
    t.boolean "is_open_by_default"
    t.integer "panel_color"
    t.integer "decision_aid_id"
    t.index ["accordion_id"], name: "index_accordion_contents_on_accordion_id"
    t.index ["decision_aid_id"], name: "index_accordion_contents_on_decision_aid_id"
  end

  create_table "accordion_object_references", id: :serial, force: :cascade do |t|
    t.integer "accordion_id"
    t.integer "object_id"
    t.string "object_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accordions", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.integer "decision_aid_ids", default: [], array: true
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "decision_aid_id"
    t.index ["decision_aid_id"], name: "index_accordions_on_decision_aid_id"
  end

  create_table "animated_icon_array_graphic_stages", id: :serial, force: :cascade do |t|
    t.integer "animated_icon_array_graphic_id"
    t.integer "total_n"
    t.string "general_label"
    t.boolean "seperate_values", default: false
    t.integer "graphic_stage_order", null: false
  end

  create_table "animated_icon_array_graphics", id: :serial, force: :cascade do |t|
    t.boolean "indicators_above", default: false
    t.integer "default_stage", default: 0
  end

  create_table "basic_page_submissions", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_user_id"
    t.integer "option_id"
    t.integer "sub_decision_id"
    t.integer "intro_page_id"
  end

  create_table "bw_question_set_responses", id: :serial, force: :cascade do |t|
    t.integer "question_set"
    t.integer "property_level_ids", array: true
    t.integer "decision_aid_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "block_number", default: 1, null: false
  end

  create_table "currently_exporting_rdts", id: :serial, force: :cascade do |t|
    t.integer "data_export_field_id"
    t.integer "decision_aid_user_id"
    t.string "thread_id", null: false
    t.index ["data_export_field_id", "decision_aid_user_id"], name: "rdt_decision_aid_user_index", unique: true
  end

  create_table "data_export_fields", id: :serial, force: :cascade do |t|
    t.string "exporter_type", null: false
    t.integer "exporter_id", null: false
    t.integer "decision_aid_id", null: false
    t.integer "data_target_type", null: false
    t.integer "data_export_field_order", null: false
    t.string "redcap_field_name"
    t.json "redcap_response_mapping"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "data_accessor"
  end

  create_table "dce_question_set_responses", id: :serial, force: :cascade do |t|
    t.integer "question_set"
    t.integer "response_value"
    t.json "property_level_hash"
    t.integer "decision_aid_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "block_number", default: 1, null: false
    t.boolean "is_opt_out", default: false
    t.integer "dce_question_set_id"
    t.index ["dce_question_set_id"], name: "index_dce_question_set_responses_on_dce_question_set_id"
    t.index ["decision_aid_id", "question_set"], name: "dce_question_set_response_index"
  end

  create_table "dce_question_sets", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_id"
    t.string "question_title"
    t.integer "dce_question_set_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dce_results_matches", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_id"
    t.integer "response_combination", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "option_match_hash"
    t.index ["decision_aid_id", "response_combination"], name: "dce_results_match_index"
  end

  create_table "decision_aid_query_parameters", id: :serial, force: :cascade do |t|
    t.string "input_name"
    t.string "output_name"
    t.boolean "is_primary"
    t.integer "decision_aid_id"
  end

  create_table "decision_aid_user_bw_question_set_responses", id: :serial, force: :cascade do |t|
    t.integer "bw_question_set_response_id"
    t.integer "decision_aid_user_id"
    t.integer "question_set"
    t.integer "best_property_level_id"
    t.integer "worst_property_level_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_aid_user_dce_question_set_responses", id: :serial, force: :cascade do |t|
    t.integer "dce_question_set_response_id"
    t.integer "decision_aid_user_id"
    t.integer "question_set"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fallback_question_set_id"
    t.boolean "option_confirmed"
    t.index ["decision_aid_user_id", "question_set", "dce_question_set_response_id"], name: "decision_aid_user_dce_question_set_response_index"
  end

  create_table "decision_aid_user_option_properties", id: :serial, force: :cascade do |t|
    t.integer "option_property_id", null: false
    t.integer "option_id", null: false
    t.integer "property_id", null: false
    t.integer "decision_aid_user_id", null: false
    t.float "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decision_aid_user_id", "option_id", "property_id", "option_property_id"], name: "decision_aid_user_option_property_index"
  end

  create_table "decision_aid_user_properties", id: :serial, force: :cascade do |t|
    t.integer "property_id", null: false
    t.integer "decision_aid_user_id", null: false
    t.integer "weight", default: 50
    t.integer "order", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "traditional_value"
    t.integer "traditional_option_id"
    t.index ["decision_aid_user_id", "property_id"], name: "decision_aid_user_property_index"
  end

  create_table "decision_aid_user_query_parameters", id: :serial, force: :cascade do |t|
    t.string "param_value"
    t.integer "decision_aid_query_parameter_id"
    t.integer "decision_aid_user_id"
  end

  create_table "decision_aid_user_responses", id: :serial, force: :cascade do |t|
    t.integer "question_response_id"
    t.text "response_value"
    t.integer "question_id", null: false
    t.integer "decision_aid_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "number_response_value"
    t.float "lookup_table_value"
    t.integer "option_id"
    t.json "json_response_value"
    t.string "selected_unit"
    t.index ["decision_aid_user_id", "question_id", "question_response_id"], name: "decision_aid_user_response_index"
  end

  create_table "decision_aid_user_sessions", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_user_id", null: false
    t.datetime "last_access", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["decision_aid_user_id"], name: "index_decision_aid_user_sessions_on_decision_aid_user_id"
  end

  create_table "decision_aid_user_skip_results", id: :serial, force: :cascade do |t|
    t.integer "source_question_page_id", null: false
    t.integer "decision_aid_user_id", null: false
    t.integer "target_type", null: false
    t.integer "target_question_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_aid_user_sub_decision_choices", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_user_id"
    t.integer "sub_decision_id"
    t.integer "option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_aid_user_summary_pages", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_user_id"
    t.integer "summary_page_id"
    t.string "summary_page_file_file_name"
    t.string "summary_page_file_content_type"
    t.bigint "summary_page_file_file_size"
    t.datetime "summary_page_file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_aid_users", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_id", null: false
    t.integer "selected_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "decision_aid_user_responses_count", default: 0, null: false
    t.integer "decision_aid_user_properties_count", default: 0, null: false
    t.integer "decision_aid_user_option_properties_count", default: 0, null: false
    t.integer "decision_aid_user_dce_question_set_responses_count", default: 0, null: false
    t.integer "decision_aid_user_bw_question_set_responses_count", default: 0, null: false
    t.integer "decision_aid_user_sub_decision_choices_count", default: 0, null: false
    t.boolean "about_me_complete", default: false
    t.boolean "quiz_complete", default: false
    t.integer "randomized_block_number"
    t.integer "unique_id_name"
    t.datetime "estimated_end_time"
    t.text "other_properties"
    t.string "platform"
  end

  create_table "decision_aids", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "options_count", default: 0, null: false
    t.integer "properties_count", default: 0, null: false
    t.integer "option_properties_count", default: 0, null: false
    t.integer "demographic_questions_count", default: 0, null: false
    t.integer "quiz_questions_count", default: 0, null: false
    t.integer "question_responses_count", default: 0, null: false
    t.text "about_information"
    t.text "options_information"
    t.text "properties_information"
    t.text "property_weight_information"
    t.text "results_information"
    t.text "quiz_information"
    t.integer "minimum_property_count", default: 0
    t.text "description_published"
    t.text "about_information_published"
    t.text "options_information_published"
    t.text "properties_information_published"
    t.text "property_weight_information_published"
    t.text "results_information_published"
    t.text "quiz_information_published"
    t.integer "icon_id"
    t.integer "footer_logos", default: [], array: true
    t.boolean "ratings_enabled"
    t.boolean "percentages_enabled"
    t.boolean "best_match_enabled"
    t.integer "chart_type", default: 0
    t.integer "decision_aid_type", null: false
    t.text "dce_information"
    t.text "dce_information_published"
    t.text "dce_specific_information"
    t.text "dce_specific_information_published"
    t.string "dce_design_file_file_name"
    t.string "dce_design_file_content_type"
    t.bigint "dce_design_file_file_size"
    t.datetime "dce_design_file_updated_at"
    t.string "dce_results_file_file_name"
    t.string "dce_results_file_content_type"
    t.bigint "dce_results_file_file_size"
    t.datetime "dce_results_file_updated_at"
    t.integer "dce_question_set_responses_count", default: 0, null: false
    t.boolean "dce_design_success", default: false
    t.boolean "dce_results_success", default: false
    t.boolean "bw_design_success", default: false
    t.string "bw_design_file_file_name"
    t.string "bw_design_file_content_type"
    t.bigint "bw_design_file_file_size"
    t.datetime "bw_design_file_updated_at"
    t.integer "bw_question_set_responses_count", default: 0, null: false
    t.text "best_worst_information"
    t.text "best_worst_information_published"
    t.text "best_worst_specific_information"
    t.text "best_worst_specific_information_published"
    t.text "other_options_information"
    t.text "other_options_information_published"
    t.integer "sub_decisions_count", default: 0, null: false
    t.boolean "has_intro_popup", default: false
    t.text "intro_popup_information"
    t.text "intro_popup_information_published"
    t.integer "summary_panels_count", default: 0, null: false
    t.string "summary_link_to_url"
    t.string "redcap_token"
    t.string "redcap_url"
    t.boolean "password_protected", default: false
    t.string "access_password"
    t.integer "intro_pages_count", default: 0, null: false
    t.string "more_information_button_text"
    t.text "final_summary_text"
    t.text "final_summary_text_published"
    t.string "summary_email_addresses", default: [], array: true
    t.integer "theme", default: 0, null: false
    t.string "best_wording", default: "Best"
    t.string "worst_wording", default: "Worst"
    t.boolean "include_admin_summary_email", default: false
    t.boolean "include_user_summary_email", default: false
    t.text "user_summary_email_text", default: "If you would like these results emailed to you, enter your email address here:"
    t.string "mysql_dbname"
    t.string "mysql_user"
    t.string "mysql_password"
    t.string "contact_phone_number"
    t.string "contact_email"
    t.boolean "include_download_pdf_button", default: false
    t.integer "maximum_property_count", default: 0
    t.string "intro_page_label", default: "Introduction"
    t.string "about_me_page_label", default: "About Me"
    t.string "properties_page_label", default: "My Values"
    t.string "results_page_label", default: "My Choice"
    t.string "quiz_page_label", default: "Review"
    t.string "summary_page_label", default: "Summary"
    t.text "opt_out_information"
    t.text "opt_out_information_published"
    t.boolean "properties_auto_submit", default: true
    t.string "opt_out_label", default: "Opt Out"
    t.string "dce_option_prefix", default: "Option"
    t.integer "current_block_number", default: 1, null: false
    t.string "best_worst_page_label", default: "My Values"
    t.boolean "hide_menu_bar", default: false
    t.boolean "open_summary_link_in_new_tab", default: true
    t.boolean "color_rows_based_on_attribute_levels", default: false
    t.boolean "compare_opt_out_to_last_selected", default: true
    t.boolean "use_latent_class_analysis", default: false
    t.integer "language_code", default: 0
    t.boolean "full_width", default: false
    t.text "custom_css"
    t.integer "static_pages_count", default: 0, null: false
    t.integer "nav_links_count", default: 0, null: false
    t.boolean "include_dce_confirmation_question", default: false
    t.text "dce_confirmation_question"
    t.text "dce_confirmation_question_published"
    t.integer "dce_type", default: 1
    t.string "begin_button_text", default: "Begin", null: false
    t.string "custom_css_file_file_name"
    t.string "custom_css_file_content_type"
    t.bigint "custom_css_file_file_size"
    t.datetime "custom_css_file_updated_at"
    t.string "dce_selection_label", default: "Which do you prefer?"
    t.string "dce_min_level_color"
    t.string "dce_max_level_color"
    t.integer "summary_pages_count", default: 0, null: false
    t.string "unique_redcap_record_identifier"
    t.integer "data_export_fields_count", default: 0, null: false
    t.index ["slug"], name: "index_decision_aids_on_slug"
  end

  create_table "download_items", id: :serial, force: :cascade do |t|
    t.integer "download_type"
    t.boolean "downloaded", default: false
    t.string "file_location"
    t.boolean "processed", default: false
    t.boolean "error", default: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "decision_aid_user_id"
    t.integer "decision_aid_id"
    t.index ["decision_aid_id"], name: "index_download_items_on_decision_aid_id"
    t.index ["decision_aid_user_id"], name: "index_download_items_on_decision_aid_user_id"
  end

  create_table "graphic_data", id: :serial, force: :cascade do |t|
    t.integer "graphic_id"
    t.string "value"
    t.string "label"
    t.string "color"
    t.integer "graphic_data_order"
    t.string "sub_value"
    t.integer "value_type"
    t.integer "sub_value_type"
    t.integer "animated_icon_array_graphic_stage_id"
    t.index ["animated_icon_array_graphic_stage_id"], name: "index_graphic_data_on_animated_icon_array_graphic_stage_id"
  end

  create_table "graphic_object_references", id: :serial, force: :cascade do |t|
    t.integer "graphic_id"
    t.integer "object_id"
    t.string "object_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "graphics", id: :serial, force: :cascade do |t|
    t.string "actable_type"
    t.integer "actable_id"
    t.integer "decision_aid_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
  end

  create_table "horizontal_bar_chart_graphics", id: :serial, force: :cascade do |t|
    t.string "selected_index"
    t.integer "selected_index_type"
    t.string "max_value"
  end

  create_table "icon_array_graphics", id: :serial, force: :cascade do |t|
    t.string "selected_index"
    t.integer "selected_index_type"
    t.integer "num_per_row"
  end

  create_table "icons", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_id", null: false
    t.string "url"
    t.integer "icon_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.index ["decision_aid_id"], name: "index_icons_on_decision_aid_id"
  end

  create_table "intro_pages", id: :serial, force: :cascade do |t|
    t.text "description"
    t.text "description_published"
    t.integer "decision_aid_id"
    t.integer "intro_page_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
  end

  create_table "latent_class_options", id: :serial, force: :cascade do |t|
    t.integer "latent_class_id"
    t.integer "option_id"
    t.float "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "latent_class_properties", id: :serial, force: :cascade do |t|
    t.integer "latent_class_id"
    t.integer "property_id"
    t.float "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "latent_classes", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_id"
    t.integer "class_order"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_chart_graphics", id: :serial, force: :cascade do |t|
    t.string "x_label"
    t.string "y_label"
    t.string "chart_title"
    t.integer "min_value"
    t.integer "max_value"
  end

  create_table "media_files", id: :serial, force: :cascade do |t|
    t.integer "media_type"
    t.integer "user_id"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "my_sql_question_params", id: :serial, force: :cascade do |t|
    t.integer "param_source"
    t.string "param_type"
    t.string "value"
    t.integer "my_sql_question_param_order"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nav_links", id: :serial, force: :cascade do |t|
    t.string "link_href"
    t.string "link_text"
    t.integer "link_location"
    t.integer "nav_link_order", null: false
    t.integer "decision_aid_id"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "option_properties", id: :serial, force: :cascade do |t|
    t.text "information"
    t.text "short_label"
    t.integer "option_id", null: false
    t.integer "property_id", null: false
    t.integer "decision_aid_id", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "information_published"
    t.text "ranking"
    t.integer "ranking_type"
    t.text "short_label_published"
    t.string "button_label"
    t.index ["decision_aid_id", "option_id", "property_id"], name: "option_property_index"
  end

  create_table "options", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "label"
    t.text "description"
    t.text "summary_text"
    t.integer "decision_aid_id", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "media_file_id"
    t.integer "question_response_array", default: [], array: true
    t.text "description_published"
    t.text "summary_text_published"
    t.integer "option_order"
    t.integer "option_id"
    t.boolean "has_sub_options", null: false
    t.integer "sub_decision_id"
    t.string "generic_name"
    t.index ["decision_aid_id"], name: "index_options_on_decision_aid_id"
    t.index ["media_file_id"], name: "index_options_on_media_file_id"
  end

  create_table "progress_trackers", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_user_id"
  end

  create_table "properties", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "selection_about"
    t.text "long_about"
    t.integer "decision_aid_id", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "selection_about_published"
    t.text "long_about_published"
    t.integer "property_order"
    t.integer "property_levels_count", default: 0, null: false
    t.string "short_label"
    t.boolean "is_property_weighable", default: true
    t.boolean "are_option_properties_weighable", default: true
    t.string "property_group_title"
    t.string "backend_identifier"
    t.index ["decision_aid_id"], name: "index_properties_on_decision_aid_id"
  end

  create_table "property_levels", id: :serial, force: :cascade do |t|
    t.text "information"
    t.text "information_published"
    t.integer "level_id"
    t.integer "property_id", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "decision_aid_id"
    t.index ["property_id"], name: "index_property_levels_on_property_id"
  end

  create_table "question_pages", id: :serial, force: :cascade do |t|
    t.integer "section"
    t.integer "question_page_order", null: false
    t.integer "decision_aid_id", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "skip_logic_target_count", default: 0, null: false
  end

  create_table "question_responses", id: :serial, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "decision_aid_id", null: false
    t.string "question_response_value"
    t.boolean "is_text_response"
    t.integer "question_response_order", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "numeric_value"
    t.string "redcap_response_value"
    t.text "popup_information"
    t.text "popup_information_published"
    t.boolean "include_popup_information", default: false
    t.integer "skip_logic_target_count", default: 0, null: false
    t.index ["decision_aid_id", "question_id"], name: "index_question_responses_on_decision_aid_id_and_question_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.text "question_text"
    t.integer "question_type", null: false
    t.integer "question_response_type", null: false
    t.integer "question_order", null: false
    t.integer "decision_aid_id", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "question_text_published"
    t.integer "question_id"
    t.integer "grid_questions_count", default: 0, null: false
    t.boolean "hidden", default: false
    t.string "response_value_calculation"
    t.json "lookup_table"
    t.integer "question_response_style"
    t.integer "sub_decision_id"
    t.integer "lookup_table_dimensions", default: [], array: true
    t.boolean "remote_data_source", default: false
    t.integer "remote_data_source_type"
    t.string "redcap_field_name"
    t.string "my_sql_procedure_name"
    t.integer "current_treatment_option_ids", default: [], array: true
    t.string "slider_left_label"
    t.string "slider_right_label"
    t.integer "slider_granularity"
    t.integer "num_decimals_to_round_to", default: 0
    t.boolean "can_change_response", default: true
    t.text "post_question_text"
    t.text "post_question_text_published"
    t.string "slider_midpoint_label"
    t.string "unit_of_measurement"
    t.text "side_text"
    t.text "side_text_published"
    t.boolean "skippable", default: false
    t.integer "special_flag", default: 1, null: false
    t.boolean "is_exclusive", default: false
    t.boolean "randomized_response_order", default: false
    t.integer "min_number"
    t.integer "max_number"
    t.integer "min_chars"
    t.integer "max_chars"
    t.string "units_array", default: [], array: true
    t.boolean "remote_data_target", default: false
    t.integer "remote_data_target_type"
    t.string "backend_identifier"
    t.integer "question_page_id"
    t.index ["decision_aid_id"], name: "index_questions_on_decision_aid_id"
  end

  create_table "section_trackers", id: :serial, force: :cascade do |t|
    t.integer "progress_tracker_id"
    t.integer "sub_decision_id"
    t.integer "page"
    t.integer "section_tracker_order"
    t.string "skip_section_target"
  end

  create_table "skip_logic_conditions", id: :serial, force: :cascade do |t|
    t.integer "skip_logic_target_id"
    t.integer "decision_aid_id"
    t.integer "condition_entity"
    t.string "entity_lookup"
    t.string "entity_value_key"
    t.string "value_to_match"
    t.integer "logical_operator"
    t.integer "skip_logic_condition_order", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skip_logic_targets", id: :serial, force: :cascade do |t|
    t.integer "question_page_id"
    t.integer "question_response_id"
    t.integer "decision_aid_id"
    t.integer "target_entity"
    t.integer "skip_question_page_id"
    t.string "skip_page_url"
    t.integer "skip_logic_target_order", null: false
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "include_query_params", default: false
  end

  create_table "static_pages", id: :serial, force: :cascade do |t|
    t.text "page_text"
    t.text "page_text_published"
    t.text "page_title"
    t.integer "static_page_order", null: false
    t.integer "decision_aid_id"
    t.text "page_slug"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sub_decisions", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_id"
    t.integer "sub_decision_order"
    t.integer "required_option_ids", default: [], array: true
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "options_information"
    t.text "options_information_published"
    t.text "other_options_information"
    t.text "other_options_information_published"
    t.text "my_choice_information"
    t.text "my_choice_information_published"
    t.text "option_question_text"
  end

  create_table "summary_pages", id: :serial, force: :cascade do |t|
    t.integer "decision_aid_id", null: false
    t.integer "summary_panels_count", default: 0, null: false
    t.boolean "include_admin_summary_email", default: false
    t.boolean "is_primary", default: false
    t.string "summary_email_addresses", array: true
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "backend_identifier"
  end

  create_table "summary_panels", id: :serial, force: :cascade do |t|
    t.integer "panel_type"
    t.text "panel_information"
    t.text "panel_information_published"
    t.integer "question_ids", default: [], array: true
    t.integer "summary_panel_order"
    t.integer "decision_aid_id"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "option_lookup_json"
    t.json "lookup_headers_json"
    t.json "summary_table_header_json"
    t.string "injectable_decision_summary_string"
    t.integer "summary_page_id", null: false
    t.index ["summary_page_id"], name: "index_summary_panels_on_summary_page_id"
  end

  create_table "user_authentications", id: :serial, force: :cascade do |t|
    t.string "token", null: false
    t.boolean "is_superuser", default: false, null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "decision_aid_id"
    t.integer "permission_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.boolean "is_superadmin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_logged_in"
    t.boolean "terms_accepted"
  end

  add_foreign_key "accordion_contents", "decision_aids"
  add_foreign_key "accordions", "decision_aids"
  add_foreign_key "options", "media_files"
end
