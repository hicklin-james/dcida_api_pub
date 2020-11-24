Rails.application.routes.draw do

  apipie
  use_doorkeeper

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :cors

  if Rails.env.test?
    post 'test/setup_e2e_env'
  end

  namespace :api, format: false do

    resources :tokens, only: [:create, :destroy]
    resources :user_authentications, only: [:create] do
      post 'reset_password', on: :collection
    end
    resources :users do
      get 'current', on: :collection
      post 'upload_user_image', on: :member
      post 'reset_password', on: :collection
      post 'create_from_admin', on: :collection
      get 'user_images', on: :member
      resources :media_files, only: [:create, :index, :destroy]
    end

    resources :decision_aids do
      get 'preview', on: :member
      get 'export', on: :member
      get 'setup_dce', on: :member
      get 'setup_bw', on: :member
      get 'test_redcap_connection', on: :member
      get 'download_user_data', on: :member
      get 'clear_user_data', on: :member
      get 'page_targets', on: :member
      post 'upload_dce_design', on: :member
      post 'upload_dce_results', on: :member
      post 'upload_bw_design', on: :member


      resources :accordions, only: [:create, :index, :update, :destroy]
      resources :sub_decisions
      resources :graphics, only: [:create, :index, :update, :destroy]

      resources :dce_question_set_responses, only: [:index] do
        get "preview", on: :collection
      end

      resources :bw_question_set_responses, only: [] do
        get "preview", on: :collection
      end

      resources :intro_pages do
        post "update_order", on: :member
        get "preview", on: :collection
      end
      resources :options do
        get "options_from_last_sub_decision", on: :collection
        get "preview", on: :collection
        post "update_order", on: :member
        post 'clone', on: :member
      end
      resources :properties do
        get 'preview', on: :collection
        post "update_order", on: :member
        post "clone", on: :member
      end
      resources :option_properties do
        get "preview", on: :collection
        post "update_bulk", on: :collection
      end
      resources :question_pages do
        post "update_order", on: :member
      end
      resources :questions do
        get "test_redcap_question", on: :collection
        post "update_order", on: :member
        post "move_question_to_page", on: :member
        get "preview", on: :collection
        post 'clone', on: :member
      end
      resources :summary_panels do
        post "update_order", on: :member
      end
      
      resources :summary_pages
      resources :data_export_fields do
        post "update_order", on: :member
        get "test_redcap_question", on: :collection
      end

      resources :nav_links do
        post "update_order", on: :member
      end
      resources :static_pages do
        post "update_order", on: :member
      end
      resources :icons, only: [:create, :index, :destroy] do
        post "update_bulk", on: :collection
      end
      resources :latent_classes do
        post "create_and_update_and_delete_bulk", on: :collection
      end

      resources :dce_question_sets, only: [:index] do
        post "update_bulk", on: :collection
      end
    end

    resources :decision_aid_users, only: [:index, :update] do
      
      post "update_from_properties", on: :member

      resources :decision_aid_user_sub_decision_choices, only: [:create, :update, :index] do 
        get "find_by_sub_decision_id", on: :collection
      end
      resources :decision_aid_user_responses, only: [:index, :create, :update] do
        post 'create_and_update_bulk', on: :collection
        post 'create_or_update_radio_from_chatbot', on: :collection
      end
      resources :decision_aid_user_properties, only: :index do
        post 'update_selections', on: :collection
      end
      resources :decision_aid_user_option_properties, only: :index do
        post 'update_user_option_properties', on: :collection
      end
      resources :decision_aid_user_dce_question_set_responses, only: [:create, :update, :index] do
        get 'find_by_question_set', on: :collection
      end
      resources :decision_aid_user_bw_question_set_responses, only: [:create, :update, :index] do
        get 'find_by_question_set', on: :collection
      end
      resources :basic_page_submissions, only: [:create, :index]
    end

    get 'decision_aid_home/get_decision_aid_user'
    get 'decision_aid_home/get_language'

    get "decision_aid_home/intro"
    get "decision_aid_home/about"
    get "decision_aid_home/options"
    get "decision_aid_home/properties"
    get "decision_aid_home/properties_post_best_worst"
    get "decision_aid_home/properties_enhanced"
    get "decision_aid_home/properties_decide"
    get "decision_aid_home/traditional_properties"
    get "decision_aid_home/best_worst"
    get "decision_aid_home/dce"
    get "decision_aid_home/results"
    get "decision_aid_home/quiz"
    get "decision_aid_home/summary"
    
    get "decision_aid_home/mail_summary_to_user"
    get "decision_aid_home/static_page"
    post "decision_aid_home/generate_pdf"
    post "decision_aid_home/open_pdf"

    get 'ping', to: proc { [200, {}, ['']] }
  end
end
