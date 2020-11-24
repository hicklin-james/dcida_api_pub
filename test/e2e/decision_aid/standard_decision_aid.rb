# require 'betterlorem'

class E2EStandardDecisionAid
  def seed(additional_params)
    
    if additional_params.nil?
      additional_params = {}
    end

    u = User.create!(
      email: "admin@tt.com", 
      password: "test123", 
      password_confirmation: "test123", 
      first_name: "Joe", 
      last_name: "Connington", 
      terms_accepted: true,
      is_superadmin: true
    )
    User.current_user = u

    da_params = {
      decision_aid_type: DecisionAid.decision_aid_types[:standard], 
      slug: "standard", 
      title: "Standard",
      about_information: BetterLorem::p(2)
    }

    if additional_params["decision_aid"]
      da_params = da_params.merge(additional_params["decision_aid"])
    end

    da = DecisionAid.create!(da_params)

    ip1 = IntroPage.create!(decision_aid_id: da.id, intro_page_order: 1, description: BetterLorem::p(5))
    ip2 = IntroPage.create!(decision_aid_id: da.id, intro_page_order: 2, description: BetterLorem::p(5))
    ip3 = IntroPage.create!(decision_aid_id: da.id, intro_page_order: 3, description: BetterLorem::p(5))

    question_order = 1

    if additional_params["questions"]
      
      textQuestionAvailable = additional_params["questions"].find{|obj| obj["type"] == "text"}
      if textQuestionAvailable
        q1 = Question.create!(
          decision_aid_id: da.id, 
          question_order: question_order, 
          question_type: "demographic", 
          question_response_type: "text",
          hidden: false,
          question_id: nil,
          question_text: BetterLorem::p(1),
          question_response_style: "normal_text",
          can_change_response: if textQuestionAvailable.key?("can_change_response") then textQuestionAvailable["can_change_response"] else true end,
          skippable: if textQuestionAvailable.key?("skippable") then textQuestionAvailable["skippable"] else false end
        )
        question_order += 1
      end

      sliderQuestionAvailable = additional_params["questions"].find{|obj| obj["type"] == "slider"}
      if sliderQuestionAvailable
        q1 = Question.create!(
          decision_aid_id: da.id, 
          question_order: question_order, 
          question_type: "demographic", 
          question_response_type: "slider",
          hidden: false,
          question_id: nil,
          question_text: BetterLorem::p(1),
          question_response_style: if sliderQuestionAvailable.key?("question_response_style") then sliderQuestionAvailable["question_response_style"] else 'horizontal_slider' end,
          can_change_response: if sliderQuestionAvailable.key?("can_change_response") then sliderQuestionAvailable["can_change_response"] else true end,
          slider_granularity: 100,
          slider_left_label: "Left",
          slider_midpoint_label: "Middle",
          slider_right_label: "Right"
        )
        question_order += 1
      end

      numberQuestionAvailable = additional_params["questions"].find{|obj| obj["type"] == "number"}
      if numberQuestionAvailable
        q1 = Question.create!(
          decision_aid_id: da.id, 
          question_order: question_order, 
          question_type: "demographic", 
          question_response_type: "number",
          hidden: false,
          question_id: nil,
          question_text: BetterLorem::p(1),
          question_response_style: 'normal_number',
          can_change_response: if numberQuestionAvailable.key?("can_change_response") then numberQuestionAvailable["can_change_response"] else true end,
          skippable: if numberQuestionAvailable.key?("skippable") then numberQuestionAvailable["skippable"] else false end,
          unit_of_measurement: "cm"
        )
        question_order += 1
      end

      radioQuestionAvailable = additional_params["questions"].find{|obj| obj["type"] == "radio"}
      if radioQuestionAvailable
        q2 = Question.create!(
          decision_aid_id: da.id, 
          question_order: question_order, 
          question_type: "demographic", 
          question_response_type: "radio",
          hidden: false,
          question_id: nil,
          question_text: BetterLorem::p(1),
          question_response_style: "horizontal_radio",
          can_change_response: if radioQuestionAvailable.key?("can_change_response") then radioQuestionAvailable["can_change_response"] else true end,
          skippable: if radioQuestionAvailable.key?("skippable") then radioQuestionAvailable["skippable"] else false end,
          question_responses_attributes: [
            {
              decision_aid_id: da.id,
              question_response_value: "Response 1",
              question_response_order: 1
            },
            {
              decision_aid_id: da.id,
              question_response_value: "Response 2",
              question_response_order: 2
            },
            {
              decision_aid_id: da.id,
              question_response_value: "Response 3",
              question_response_order: 3
            }
          ]
        )
        question_order += 1
      end

      rankingQuestionAvailable = additional_params["questions"].find{|obj| obj["type"] == "ranking"}
      if rankingQuestionAvailable
        q2 = Question.create!(
          decision_aid_id: da.id, 
          question_order: question_order, 
          question_type: "demographic", 
          question_response_type: "ranking",
          hidden: false,
          question_id: nil,
          question_text: BetterLorem::p(1),
          question_response_style: "normal_ranking",
          can_change_response: if rankingQuestionAvailable.key?("can_change_response") then rankingQuestionAvailable["can_change_response"] else true end,
          skippable: if rankingQuestionAvailable.key?("skippable") then rankingQuestionAvailable["skippable"] else false end,
          question_responses_attributes: [
            {
              decision_aid_id: da.id,
              question_response_value: "Response 1",
              question_response_order: 1
            },
            {
              decision_aid_id: da.id,
              question_response_value: "Response 2",
              question_response_order: 2
            },
            {
              decision_aid_id: da.id,
              question_response_value: "Response 3",
              question_response_order: 3
            }
          ]
        )
        question_order += 1
      end
    end
  end
end