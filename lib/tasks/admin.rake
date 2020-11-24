#encoding: utf-8 
namespace :admin do
  task :create_user, [:user_email, :user_password, :is_superadmin] => :environment do |t, args|
    args.with_defaults(:user_email => "admin@tt.com", :user_password => "test123", :is_superadmin => false)
    if args[:user_email] and args[:user_password] and args[:is_superadmin]
      if User.where(email: args[:user_email]).length == 0
        User.create!(email: args[:user_email], password: args[:user_password], password_confirmation: args[:user_password], terms_accepted: true, is_superadmin: args[:is_superadmin], first_name: "Admin", last_name: "User")
        puts "User successfully created with email: #{args[:user_email]}".green
      else
        puts "User already exists with email: #{args[:user_email]}".red
      end
    end
  end

  task :fix_counters, [] => :environment do |t, args|
    puts "Beginning counter fix"
    BwQuestionSetResponse.counter_culture_fix_counts
    DceQuestionSetResponse.counter_culture_fix_counts
    DecisionAidUserBwQuestionSetResponse.counter_culture_fix_counts
    DecisionAidUserDceQuestionSetResponse.counter_culture_fix_counts
    DecisionAidUserOptionProperty.counter_culture_fix_counts
    DecisionAidUserProperty.counter_culture_fix_counts
    DecisionAidUserResponse.counter_culture_fix_counts
    DecisionAidUserSubDecisionChoice.counter_culture_fix_counts
    Option.counter_culture_fix_counts
    Property.counter_culture_fix_counts
    OptionProperty.counter_culture_fix_counts
    PropertyLevel.counter_culture_fix_counts
    Question.counter_culture_fix_counts
    QuestionResponse.counter_culture_fix_counts
    SubDecision.counter_culture_fix_counts
    IntroPage.counter_culture_fix_counts
    SummaryPanel.counter_culture_fix_counts
    StaticPage.counter_culture_fix_counts
    NavLink.counter_culture_fix_counts
    puts "Fixed counters"
  end

  # triggers the save callbacks so that accordion fields are updated
  task :update_published_fields, [] => :environment do |t, args|
    decision_aids = DecisionAid.all
    decision_aids.each do |da|
      options = da.options
      properties = da.properties
      option_properties = da.option_properties
      questions = da.questions
      options.each do |o|
        o.save
      end
      properties.each do |p|
        p.save
      end
      option_properties.each do |op|
        op.save
      end
      questions.each do |q|
        q.save
      end
      da.save
    end
    AccordionContent.all.each do |ac|
      ac.save
    end
    puts "Successfully updated all published fields".green
  end

  task :fix_slider_values, [] => :environment do |t, args|
    questions = Question.where(question_response_type: Question.question_response_types[:slider])
    questions.each do |q|
      q.min_number = 0
      q.max_number = q.slider_granularity
      q.min_chars = q.slider_granularity / 2
      q.slider_granularity = 1
      q.save!
    end
  end

  task :fix_ordered_models, [] => :environment do |t, args|
    decision_aids = DecisionAid.all
    decision_aids.each do |da|
      da.options.where(:option_id => nil).each_with_index do |o, i|
        o.option_order = i + 1
        o.save
        o.sub_options.each_with_index do |so, ii|
          so.option_order = ii + 1
          so.save
        end
      end
      da.properties.each_with_index do |p, i|
        p.property_order = i + 1
        p.save
      end
      da.demographic_questions.where(question_id: nil).ordered.each_with_index do |q, i|
        q.question_responses.each_with_index do |qr, index|
          qr.question_response_order = index
          qr.save
        end
        q.question_order = i + 1
        q.save
      end
      da.quiz_questions.where(question_id: nil).ordered.each_with_index do |q, i|
        q.question_responses.each_with_index do |qr, index|
          qr.question_response_order = index
          qr.save
        end
        q.question_order = i + 1
        q.save
      end
      da.summary_pages.each do |spa|
        spa.summary_panels.ordered.each_with_index do |sp, index|
          sp.summary_panel_order = index + 1
          sp.save
        end
      end
    end
    puts "Successfully fixed ordered models".green
  end
end