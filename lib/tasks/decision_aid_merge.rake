IR = /\[question id=("|')([0-9]+)("|')( numeric)?( json_key='(.*?)')?\]/
AR = /\[accordion id="([0-9]+)"\]/
GR = /\[graphic id="([0-9]+)"\]/
QCR = /\[question_([0-9]+)(_numeric)?(_json_key='(.*?)')?\]/

namespace :decision_aid_merge do
  task :merge_databases, [:source_decision_aid_id, :source_conn, :dest_conn, :user_id] => :environment do |t, args|

    ActiveRecord::Base.establish_connection args[:source_conn]
    decision_aid = DecisionAid.find(args[:source_decision_aid_id])

    accordions_hash = Hash.new
    accordion_contents_hash = Hash.new

    def copy_accordions(args, accordions_hash, accordion_contents_hash)
      ActiveRecord::Base.establish_connection args[:source_conn]
      accordions = Accordion.where(user_id: args[:user_id]).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      accordions.each do |a|
        new_a = a.dup
        new_a.save!
        accordions_hash[a.id] = new_a.id

        ActiveRecord::Base.establish_connection args[:source_conn]
        acs = AccordionContent.where(id: a.id).load
        ActiveRecord::Base.establish_connection args[:dest_conn]
        acs.each do |ac|
          new_ac = ac.dup
          new_ac.accordion_id = new_a.id
          new_ac.save!
          accordion_contents_hash[ac.id] = new_ac.id
        end
      end
    end

    def clone_da(decision_aid, args, accordions_hash, accordion_contents_hash)
      options_hash = Hash.new
      properties_hash = Hash.new
      property_levels_hash = Hash.new
      option_properties_hash = Hash.new
      questions_hash = Hash.new
      question_responses_hash = Hash.new
      dce_question_set_responses_hash = Hash.new
      dce_results_matches_hash = Hash.new
      bw_question_set_responses_hash = Hash.new
      sub_decisions_hash = Hash.new
      icons_hash = Hash.new
      intro_pages_hash = Hash.new
      summary_panels_hash = Hash.new
      graphics_hash = Hash.new

      ActiveRecord::Base.establish_connection args[:dest_conn]
      new_da = decision_aid.dup
      new_da.dce_design_file = decision_aid.dce_design_file if decision_aid.dce_design_file.exists?
      new_da.dce_results_file = decision_aid.dce_results_file if decision_aid.dce_results_file.exists?
      new_da.bw_design_file = decision_aid.bw_design_file if decision_aid.bw_design_file.exists?
      new_da.slug = "#{decision_aid.slug}_clone"
      new_da.title = "#{decision_aid.title} clone"
      new_da.save!

      # this created a sub_decision, so we should delete it before
      # we copy the old ones over
      new_da.sub_decisions.destroy_all

      # sub questions are last, so parent questions are guaranteed to exist
      # by the time we get to the sub questions, so it is safe to use questions_hash
      ActiveRecord::Base.establish_connection args[:source_conn]
      qs = Question.unscoped.where(decision_aid_id: decision_aid.id).order("questions.question_id ASC NULLS FIRST").load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      qs.each do |q|
        new_q = q.dup
        new_q.skip_validate_grid_questions = true
        new_q.skip_validate_responses_length = true
        new_q.decision_aid_id = new_da.id
        new_q.sub_decision_id = sub_decisions_hash[q.sub_decision_id]
        new_q.question_id = questions_hash[q.question_id]
        new_q.save!
        questions_hash[q.id] = new_q.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      sds = SubDecision.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      sds.each do |sd|
        new_sd = sd.dup
        new_sd.decision_aid_id = new_da.id
        new_sd.save!
        sub_decisions_hash[sd.id] = new_sd.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      ips = IntroPage.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      ips.each do |ip|
        new_ip = ip.dup
        new_ip.decision_aid_id = new_da.id
        new_ip.save!
        intro_pages_hash[ip.id] = new_ip.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      sps = SummaryPanel.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      sps.each do |sp|
        new_sp = sp.dup
        new_sp.decision_aid_id = new_da.id
        new_sp.save!
        summary_panels_hash[sp.id] = new_sp.id
      end
      
      ActiveRecord::Base.establish_connection args[:source_conn]
      qrs = QuestionResponse.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      qrs.each do |qr|
        new_qr = qr.dup
        new_qr.decision_aid_id = new_da.id
        new_qr.question_id = questions_hash[qr.question_id]
        new_qr.save!
        question_responses_hash[qr.id] = new_qr.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      os = Option.where(decision_aid_id: decision_aid.id).order("options.option_id ASC NULLS FIRST").load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      # sub options are last, so parent options are guaranteed to exist
      # by the time we get to the sub options, so it is safe to use options_hash
      os.each do |o|
        new_o = o.dup
        new_o.decision_aid_id = new_da.id
        new_o.sub_decision_id = sub_decisions_hash[o.sub_decision_id]
        new_question_response_array = []
        o.question_response_array.each do |qr_id|
          new_question_response_array.push question_responses_hash[qr_id]
        end
        new_o.question_response_array = new_question_response_array
        new_o.save!
        options_hash[o.id] = new_o.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      ps = Property.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      ps.each do |p|
        new_p = p.dup
        new_p.decision_aid_id = new_da.id
        new_p.save!
        properties_hash[p.id] = new_p.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      ops = OptionProperty.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      ops.each do |op|
        new_op = op.dup
        new_op.decision_aid_id = new_da.id
        new_op.option_id = options_hash[op.option_id]
        new_op.property_id = properties_hash[op.property_id]
        new_op.save!
        option_properties_hash[op.id] = new_op.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      pls = PropertyLevel.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      pls.each do |pl|
        new_pl = pl.dup
        new_pl.decision_aid_id = new_da.id
        new_pl.property_id = properties_hash[pl.property_id]
        new_pl.save!
        property_levels_hash[pl.id] = new_pl.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      dcrs = DceQuestionSetResponse.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      dcrs.each do |dceqsr|
        new_dceqsr = dceqsr.dup
        new_dceqsr.decision_aid_id = new_da.id
        new_property_level_hash = Hash.new
        dceqsr.property_level_hash.each do |k,v|
          new_property_level_hash[property_levels_hash[k.to_i]] = v
        end
        new_dceqsr.property_level_hash = new_property_level_hash
        new_dceqsr.save!
        dce_question_set_responses_hash[dceqsr.id] = new_dceqsr.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      drms = DceResultsMatch.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      drms.each do |drm|
        new_drm = drm.dup
        new_drm.decision_aid_id = new_da.id
        new_option_match_hash = Hash.new
        drm.option_match_hash.each do |k, v|
          new_key = []
          k.each do |a|
            inner_key = []
            a.each do |qr_id|
              inner_key.push question_responses_hash[qr_id.to_i]
            end
            new_key.push inner_key
          end
          new_value = Hash.new
          v.each do |kk, vv|
            new_value[options_hash[kk.to_i]] = vv
          end
          new_option_match_hash[new_key] = new_value
        end
        new_drm.option_match_hash = new_option_match_hash
        new_drm.save!
        dce_results_matches_hash[drm.id] = new_drm.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      bwrs = BwQuestionSetResponse.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      bwrs.each do |bwqsr|
        new_bwqsr = bwqsr.dup
        new_bwqsr.decision_aid_id = new_da.id
        new_property_level_ids = []
        bwqsr.property_level_ids.each do |pl_id|
          new_property_level_ids.push property_levels_hash[pl_id]
        end
        new_bwqsr.property_level_ids = new_property_level_ids
        new_bwqsr.save!
        bw_question_set_responses_hash[bwqsr.id] = new_bwqsr
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      ics = Icon.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      ics.each do |icon|
        new_icon = icon.dup
        new_icon.decision_aid_id = new_da.id
        new_icon.image = icon.image if icon.image.exists?
        new_icon.save!
        icons_hash[icon.id] = new_icon.id
      end

      ActiveRecord::Base.establish_connection args[:source_conn]
      gs = Graphic.where(decision_aid_id: decision_aid.id).load
      ActiveRecord::Base.establish_connection args[:dest_conn]
      gs.each do |graphic|
        new_graphic = graphic.dup
        new_graphic.decision_aid_id = new_da.id
        new_graphic.save!
        graphics_hash[graphic.id] = new_graphic.id
      end

      accordion_contents_hash.each do |key, value|
        a = AccordionContent.find(value)
        if AccordionContent.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          AccordionContent::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        a.save!
      end

      ActiveRecord::Base.establish_connection args[:dest_conn]
      options_hash.each do |key, value|
        a = Option.find(value)
        if Option.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          Option::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if  Option.const_defined? :INJECTABLE_ATTRIBUTES
          Option::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      properties_hash.each do |key, value|
        a = Property.find(value)
        if Property.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          Property::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if Property.const_defined? :INJECTABLE_ATTRIBUTES
          Property::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      property_levels_hash.each do |key, value|
        a = PropertyLevel.find(value)
        if PropertyLevel.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          PropertyLevel::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if PropertyLevel.const_defined? :INJECTABLE_ATTRIBUTES
          PropertyLevel::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      option_properties_hash.each do |key, value|
        a = OptionProperty.find(value)
        if OptionProperty.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          OptionProperty::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if OptionProperty.const_defined? :INJECTABLE_ATTRIBUTES
          OptionProperty::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      # questions are a bit special
      questions_hash.each do |key, value|
        a = Question.find(value)
        if Question.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          Question::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if Question.const_defined? :INJECTABLE_ATTRIBUTES
          Question::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        if a.question_response_type == "lookup_table"
          a.lookup_table_dimensions = a.lookup_table_dimensions.map{|id| questions_hash[id.to_i]}
          new_lookup_table = recursively_update_lookup_hash(a.lookup_table, question_responses_hash)
          a.lookup_table = new_lookup_table
        end
        if (a.hidden && !a.remote_data_source) && (a.question_response_type == "radio" || a.question_response_type == "yes_no" || a.question_response_type == "number")
          a.response_value_calculation.gsub!(QCR) do |match|
            question_id = $1.to_i
            if questions_hash[question_id]
              match.gsub("[question_#{$1}", "[question_#{questions_hash[question_id]}")
            else
              match
            end
          end
        end
        a.save!
      end

      question_responses_hash.each do |key, value|
        a = QuestionResponse.find(value)
        if QuestionResponse.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          QuestionResponse::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if QuestionResponse.const_defined? :INJECTABLE_ATTRIBUTES
          QuestionResponse::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      dce_question_set_responses_hash.each do |key, value|
        a = DceQuestionSetResponse.find(value)
        if DceQuestionSetResponse.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          DceQuestionSetResponse::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if DceQuestionSetResponse.const_defined? :INJECTABLE_ATTRIBUTES
          DceQuestionSetResponse::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      dce_results_matches_hash.each do |key, value|
        a = DceResultsMatch.find(value)
        if DceResultsMatch.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          DceResultsMatch::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if DceResultsMatch.const_defined? :INJECTABLE_ATTRIBUTES
          DceResultsMatch::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      bw_question_set_responses_hash.each do |key, value|
        a = BwQuestionSetResponse.find(value)
        if BwQuestionSetResponse.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          BwQuestionSetResponse::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if BwQuestionSetResponse.const_defined? :INJECTABLE_ATTRIBUTES
          BwQuestionSetResponse::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      sub_decisions_hash.each do |key, value|
        a = SubDecision.find(value)
        if SubDecision.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          SubDecision::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if SubDecision.const_defined? :INJECTABLE_ATTRIBUTES
          SubDecision::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      icons_hash.each do |key, value|
        a = Icon.find(value)
        if Icon.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          Icon::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if Icon.const_defined? :INJECTABLE_ATTRIBUTES
          Icon::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      intro_pages_hash.each do |key, value|
        a = IntroPage.find(value)
        if IntroPage.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          IntroPage::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if IntroPage.const_defined? :INJECTABLE_ATTRIBUTES
          IntroPage::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      summary_panels_hash.each do |key, value|
        a = SummaryPanel.find(value)
        if SummaryPanel.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          SummaryPanel::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if SummaryPanel.const_defined? :INJECTABLE_ATTRIBUTES
          SummaryPanel::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      if DecisionAid.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
        DecisionAid::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
          update_has_attached_item_refs(new_da, it, accordions_hash, graphics_hash)
        end
      end
      if DecisionAid.const_defined? :INJECTABLE_ATTRIBUTES
        DecisionAid::INJECTABLE_ATTRIBUTES.each do |it|
          update_injectable_attribute_refs(new_da, it, questions_hash)
        end
      end

      new_da.save!

      new_da.icon_id = icons_hash[decision_aid.icon_id]
      new_da.save!
    end

    def recursively_update_lookup_hash(old_hash, question_responses_hash)
      new_hash = Hash.new
      old_hash.map do |key, value| 
        new_key = question_responses_hash[key.to_i].to_s
        new_hash[new_key] = value.kind_of?(Hash) ? recursively_update_lookup_hash(value, question_responses_hash) : value
        new_hash[new_key] = value.collect{ |obj| recursively_update_lookup_hash(obj, question_responses_hash) if obj.kind_of?(Hash)} if value.kind_of?(Array)
      end
      new_hash

      # old_hash.each do |k, v|
      #   if v.is_a?(Hash)
      #     new_hash[question_responses_hash[k.to_i].to_s] = v
      #     keys.push question_responses_hash[k.to_i].to_s
      #     add_to_hash(new_hash, keys, v)
      #     recursively_update_lookup_hash(new_hash, v, question_responses_hash, keys)
      #   else
      #     keys.push question_responses_hash[k.to_i].to_s
      #     add_to_hash(new_hash, keys, v)
      #   end
      # end
      # new_hash
    end

    def add_to_hash(hash, keys, value)
      curr_key = keys.first
      case keys.size
        when 1 then hash[curr_key] = value
        else add_to_hash(hash[curr_key], keys[1..-1], value)
      end
      hash
    end

    def update_has_attached_item_refs(item, atr, accordions_hash, graphics_hash)
      if item[atr]
        item[atr].gsub!(AR) do |match|
          accordion_id = $1.to_i
          if accordions_hash[accordion_id]
            match.gsub("[accordion id=\"#{$1}\"", "[accordion id=\"#{accordions_hash[accordion_id]}\"")
          else
            match
          end
        end
      end
      if item[atr]
        item[atr].gsub!(GR) do |match|
          graphic_id = $1.to_i
          if graphics_hash[graphic_id]
            match.gsub("[graphic id=\"#{$1}\"", "[graphic id=\"#{graphics_hash[graphic_id]}\"")
          else
            match
          end
        end
      end
    end

    def update_injectable_attribute_refs(item, atr, questions_hash)
      if item[atr]
        item[atr].gsub!(IR) do |match|
          question_id = $2.to_i
          if questions_hash[question_id]
            match.gsub("[question id=#{$1}#{$2}", "[question id=#{$1}#{questions_hash[question_id]}")
          else
            match
          end
        end
      end
    end

    copy_accordions(args, accordions_hash, accordion_contents_hash)
    clone_da(decision_aid, args, accordions_hash, accordion_contents_hash)

  end
end