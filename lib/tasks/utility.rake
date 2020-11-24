#encoding: utf-8 
namespace :utility do
  task :migrate_to_multiple_questions_per_page, [] => :environment do |t, args|
    DecisionAid.all.each do |da|
      # demographic questions
      first_demo_question = da.demographic_questions.ordered.where(hidden: false, question_id: nil).first

      if !da.about_information.blank?
        q = Question.new(
          decision_aid_id: da.id,
          question_text: da.about_information_published,
          question_order: 0,
          question_type: Question.question_types["demographic"],
          question_response_type: Question.question_response_types["heading"],
          question_response_style: Question.question_response_styles["normal_heading"],
          hidden: false,
          num_decimals_to_round_to: 0,
          can_change_response: false,
          skippable: true
        )

        q.save!(validate: false)

        if first_demo_question
          da.decision_aid_users.each do |dau|
            daur = DecisionAidUserResponse.find_by(decision_aid_user_id: dau.id, question_id: first_demo_question.id)
            if daur
              DecisionAidUserResponse.create!(decision_aid_user_id: dau.id, question_id: q.id)
            end
          end
        end
      end

      visible_demographic_questions = da.demographic_questions.ordered.where(hidden: false, question_id: nil)

      visible_demographic_questions.each_with_index do |q, i|
        qp = QuestionPage.create!(decision_aid_id: da.id, section: "about", question_page_order: i+1)
        q.question_page_id = qp.id
        q.question_order = 1
        q.save!
      end
      
      visible_demographic_questions = da.demographic_questions.ordered.where(hidden: false, question_id: nil)
      visible_demographic_questions.each_with_index do |q, i|
        SkipLogicTarget.where(question_page_id: q.id).each do |slt|

          qid = slt.question_page_id
          if qid
            q = Question.find_by(id: qid)
            if q
              if q.question_page_id
                qp = QuestionPage.find_by(id: q.question_page_id)
                if qp
                  slt.question_page_id = qp.id
                  slt.save!
                end
              end
            end
          end

          old_question_id = slt.skip_question_page_id
          fq = Question.find_by(id: old_question_id)
          if fq
            new_page_id = fq.question_page_id
            slt.skip_question_page_id = new_page_id
            slt.save!
          end
        end

        if q.question_responses.length > 0
          q.question_responses.each do |qr|
            qr.skip_logic_targets.each do |slt|
              old_question_id = slt.skip_question_page_id
              fq = Question.find_by(id: old_question_id)
              if fq
                new_page_id = fq.question_page_id
                slt.skip_question_page_id = new_page_id
                slt.save!
              end
            end
          end
        end
      end

      # quiz questions
      first_quiz_question = da.quiz_questions.ordered.where(hidden: false, question_id: nil).first

      if !da.quiz_information.blank?
        q = Question.new(
          decision_aid_id: da.id,
          question_text: da.quiz_information_published,
          question_order: 0,
          question_type: Question.question_types["quiz"],
          question_response_type: Question.question_response_types["heading"],
          question_response_style: Question.question_response_styles["normal_heading"],
          hidden: false,
          num_decimals_to_round_to: 0,
          can_change_response: false,
          skippable: true
        )

        q.save!(validate: false)

        if first_quiz_question
          da.decision_aid_users.each do |dau|
            daur = DecisionAidUserResponse.find_by(decision_aid_user_id: dau.id, question_id: first_quiz_question.id)
            if daur
              DecisionAidUserResponse.create!(decision_aid_user_id: dau.id, question_id: q.id)
            end
          end
        end
      end

      visible_quiz_questions = da.quiz_questions.ordered.where(hidden: false, question_id: nil)

      visible_quiz_questions.each_with_index do |q, i|
        qp = QuestionPage.create!(decision_aid_id: da.id, section: "quiz", question_page_order: i+1)
        q.question_page_id = qp.id
        q.save!
      end

      visible_quiz_questions = da.quiz_questions.ordered.where(hidden: false, question_id: nil)
      visible_quiz_questions.each_with_index do |q, i|
        SkipLogicTarget.where(question_page_id: q.id).each do |slt|
          
          qid = slt.question_page_id
          if qid
            q = Question.find_by(id: qid)
            if q
              if q.question_page_id
                qp = QuestionPage.find_by(id: q.question_page_id)
                if qp
                  slt.question_page_id = qp.id
                  slt.save!
                end
              end
            end
          end

          old_question_id = slt.skip_question_page_id
          fq = Question.find_by(id: old_question_id)
          if fq
            new_page_id = fq.question_page_id
            slt.skip_question_page_id = new_page_id
            slt.save!
          end
        end

        if q.question_responses.length > 0
          q.question_responses.each do |qr|
            qr.skip_logic_targets.each do |slt|
              old_question_id = slt.skip_question_page_id
              fq = Question.find_by(id: old_question_id)
              if fq
                new_page_id = fq.question_page_id
                slt.skip_question_page_id = new_page_id
                slt.save!
              end
            end
          end
        end
      end

      # update skip results
      dausrs = DecisionAidUserSkipResult.all
      dausrs.each do |dausr|
        old_question_id = dausr.target_question_page_id
        q = Question.find_by(id: old_question_id)
        if q
          new_page_id = q.question_page_id
          dausr.target_question_page_id = new_page_id
          dausr.save!
        end
      end
    end
    
    DecisionAidUserSkipResult.all.each do |sr|
      sqid = sr.source_question_page_id
      tqid = sr.target_question_page_id

      sq = Question.find_by(id: sqid)
      tq = Question.find_by(id: tqid)

      if sq
        sr.source_question_page_id = sq.question_page_id

        if tq
          sr.target_question_page_id = tq.question_page_id
        end
      end

      sr.save!
    end
  end
end
