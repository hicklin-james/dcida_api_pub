class DecisionAidCloneService

  INJECTABLE_REGEX = /\[question id=("|')([0-9]+)("|')( numeric)?( json_key='(.*?)')?\]/
  ACCORDION_REGEX = /\[accordion id="([0-9]+)"\]/
  GRAPHIC_REGEX = /\[graphic id="([0-9]+)"\]/
  QUESTION_CALC_REGEX = /\[question_([0-9]+)\]/

  def initialize(decision_aid_id, source_conn=nil, dest_conn=nil)
    @decision_aid_id = decision_aid_id
    if source_conn and dest_conn
      @source_connection_hash = source_conn
      @dest_connection_hash = dest_conn
      @diff_connections = true
    end
  end

  def clone(newslug=nil)
    # hashes to keep track of old and new ids
    # format is: {old_id => new_id}
    options_hash = Hash.new
    properties_hash = Hash.new
    property_levels_hash = Hash.new
    option_properties_hash = Hash.new
    question_pages_hash = Hash.new
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
    latent_classes_hash = Hash.new
    latent_class_options_hash = Hash.new
    latent_class_properties_hash = Hash.new
    dce_question_sets_hash = Hash.new
    accordions_hash = Hash.new
    accordion_contents_hash = Hash.new
    static_pages_hash = Hash.new
    nav_links_hash = Hash.new
    skip_logic_targets_hash = Hash.new
    skip_logic_conditions_hash = Hash.new
    summary_pages_hash = Hash.new

    #ActiveRecord::Base.transaction do

      #copy_accordions(@decision_aid.created_by_user_id, accordions_hash, accordion_contents_hash)
      new_da = nil
      da_attrs = nil
      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
        da_attrs = DecisionAid.find(@decision_aid_id).attributes
        ActiveRecord::Base.establish_connection @dest_connection_hash
      else
        da_attrs = DecisionAid.find(@decision_aid_id).attributes
      end
      @decision_aid = DecisionAid.cross_clone_hash(da_attrs)
      new_da = @decision_aid.dup
      #new_da.dce_design_file = @decision_aid.dce_design_file if @decision_aid.dce_design_file
      #new_da.dce_results_file = @decision_aid.dce_results_file if @decision_aid.dce_results_file
      #new_da.bw_design_file = @decision_aid.bw_design_file if @decision_aid.bw_design_file
      if newslug.nil?
        new_da.slug = "#{@decision_aid.slug}_clone"
      else
        new_da.slug = newslug
      end
      new_da.title = "#{@decision_aid.title} clone"

      # set all counts to 0 initially
      counter_columns = ["options_count", "properties_count", "option_properties_count", "demographic_questions_count", 
                         "quiz_questions_count", "question_responses_count", "dce_question_set_responses_count", 
                         "bw_question_set_responses_count", "sub_decisions_count", "summary_pages_count", "intro_pages_count", 
                         "static_pages_count", "nav_links_count"]

      counter_columns.each do |cc|
        new_da[cc.to_sym] = 0
      end

      new_da.save!


      # this created a sub_decision, so we should delete it before
      # we copy the old ones over
      new_da.sub_decisions.destroy_all

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      SubDecision.where(decision_aid_id: @decision_aid_id).ordered.each do |sd|
        sd_attrs = sd.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_sd = SubDecision.cross_clone_hash(sd_attrs)
        new_sd.decision_aid_id = new_da.id
        new_sd.save!
        sub_decisions_hash[sd.id] = new_sd.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      QuestionPage.unscoped.where(decision_aid_id: @decision_aid_id).ordered.each do |qp|
        qp_attrs = qp.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_qp = QuestionPage.cross_clone_hash(qp_attrs)
        new_qp.decision_aid_id = new_da.id
        new_qp.save!
        question_pages_hash[qp.id] = new_qp.id
      end

      # sub questions are last, so parent questions are guaranteed to exist
      # by the time we get to the sub questions, so it is safe to use questions_hash
      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      Question.unscoped.where(decision_aid_id: @decision_aid_id).order("questions.question_id ASC NULLS FIRST").ordered.each do |q|
        q_attrs = q.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_q = Question.cross_clone_hash(q_attrs)
        new_q.skip_validate_grid_questions = true
        new_q.skip_validate_responses_length = true
        new_q.decision_aid_id = new_da.id
        new_q.sub_decision_id = sub_decisions_hash[q.sub_decision_id]
        new_q.question_id = questions_hash[q.question_id]
        new_q.question_page_id = question_pages_hash[q.question_page_id]
        new_q.save!
        questions_hash[q.id] = new_q.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      IntroPage.where(decision_aid_id: @decision_aid_id).ordered.each do |ip|
        ip_attrs = ip.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_ip = IntroPage.cross_clone_hash(ip_attrs)
        new_ip.decision_aid_id = new_da.id
        new_ip.save!
        intro_pages_hash[ip.id] = new_ip.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      SummaryPage.where(decision_aid_id: @decision_aid_id).each do |sp|
        sp_attrs = sp.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_sp = SummaryPage.cross_clone_hash(sp_attrs)
        new_sp.decision_aid_id = new_da.id
        new_sp.summary_panels_count = 0
        new_sp.save!
        summary_pages_hash[sp.id] = new_sp.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      SummaryPanel.where(decision_aid_id: @decision_aid_id).ordered.each do |sp|
        sp_attrs = sp.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_sp = SummaryPanel.cross_clone_hash(sp_attrs)
        new_sp.decision_aid_id = new_da.id
        new_sp.summary_page_id = summary_pages_hash[sp.summary_page_id]
        new_sp.save!
        summary_panels_hash[sp.id] = new_sp.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end      
      QuestionResponse.where(decision_aid_id: @decision_aid_id).each do |qr|
        qr_attrs = qr.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_qr = QuestionResponse.cross_clone_hash(qr_attrs)
        new_qr.decision_aid_id = new_da.id
        new_qr.question_id = questions_hash[qr.question_id]
        new_qr.save!
        question_responses_hash[qr.id] = new_qr.id
      end

      # sub options are last, so parent options are guaranteed to exist
      # by the time we get to the sub options, so it is safe to use options_hash
      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      Option.where(decision_aid_id: @decision_aid_id).order("options.option_id ASC NULLS FIRST").each do |o|
        o_attrs = o.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_o = Option.cross_clone_hash(o_attrs)
        new_o.decision_aid_id = new_da.id
        new_o.sub_decision_id = sub_decisions_hash[o.sub_decision_id]
        new_question_response_array = []
        if o.question_response_array
          o.question_response_array.each do |qr_id|
            new_question_response_array.push question_responses_hash[qr_id]
          end
        end
        new_o.question_response_array = new_question_response_array
        if o.option_id
          new_o.option_id = options_hash[o.option_id]
        end
        if !new_o.has_sub_options 
          new_o.has_sub_options = false
        end
        new_o.save!
        options_hash[o.id] = new_o.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      Property.where(decision_aid_id: @decision_aid_id).ordered.each do |p|
        p_attrs = p.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_p = Property.cross_clone_hash(p_attrs)
        new_p.decision_aid_id = new_da.id
        new_p.save!
        properties_hash[p.id] = new_p.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      OptionProperty.where(decision_aid_id: @decision_aid_id).each do |op|
        op_attrs = op.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_op = OptionProperty.cross_clone_hash(op_attrs)
        new_op.decision_aid_id = new_da.id
        new_op.option_id = options_hash[op.option_id]
        new_op.property_id = properties_hash[op.property_id]
        new_op.save!
        option_properties_hash[op.id] = new_op.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      PropertyLevel.where(decision_aid_id: @decision_aid_id).ordered.each do |pl|
        pl_attrs = pl.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_pl = PropertyLevel.cross_clone_hash(pl_attrs)
        new_pl.decision_aid_id = new_da.id
        new_pl.property_id = properties_hash[pl.property_id]
        new_pl.save!
        property_levels_hash[pl.id] = new_pl.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      StaticPage.where(decision_aid_id: @decision_aid_id).ordered.each do |sp|
        sp_attrs = sp.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_sp = StaticPage.cross_clone_hash(sp_attrs)
        new_sp.decision_aid_id = new_da.id
        new_sp.save!
        static_pages_hash[sp.id] = new_sp.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      DceQuestionSet.where(decision_aid_id: @decision_aid_id).ordered.each do |dceqs|
        dceqs_attrs = dceqs.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_dceqs = DceQuestionSet.cross_clone_hash(dceqs_attrs)
        new_dceqs.decision_aid_id = new_da.id
        new_dceqs.save!
        dce_question_sets_hash[dceqs.id] = new_dceqs.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      DceQuestionSetResponse.where(decision_aid_id: @decision_aid_id).each do |dceqsr|
        dceqsr_attrs = dceqsr.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_dceqsr = DceQuestionSetResponse.cross_clone_hash(dceqsr_attrs)
        new_dceqsr.decision_aid_id = new_da.id
        new_property_level_hash = Hash.new
        dceqsr.property_level_hash.each do |k,v|
          new_property_level_hash[properties_hash[k.to_i]] = v
        end
        new_dceqsr.property_level_hash = new_property_level_hash
        new_dceqsr.dce_question_set_id = dce_question_sets_hash[dceqsr.dce_question_set_id]
        new_dceqsr.save!
        dce_question_set_responses_hash[dceqsr.id] = new_dceqsr.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      DceResultsMatch.where(decision_aid_id: @decision_aid_id).each do |drm|
        drm_attrs = drm.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_drm = DceResultsMatch.cross_clone_hash(drm_attrs)
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

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      BwQuestionSetResponse.where(decision_aid_id: @decision_aid_id).each do |bwqsr|
        bwqsr_attrs = bwqsr.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_bwqsr = BwQuestionSetResponse.cross_clone_hash(bwqsr_attrs)
        new_bwqsr.decision_aid_id = new_da.id
        new_property_level_ids = []
        bwqsr.property_level_ids.each do |pl_id|
          new_property_level_ids.push property_levels_hash[pl_id]
        end
        new_bwqsr.property_level_ids = new_property_level_ids
        new_bwqsr.save!
        bw_question_set_responses_hash[bwqsr.id] = new_bwqsr
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      Icon.where(decision_aid_id: @decision_aid_id).each do |icon|
        icon_attrs = icon.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_icon = Icon.cross_clone_hash(icon_attrs)
        new_icon.decision_aid_id = new_da.id
        if icon.image.exists?
          new_icon.image = icon.image
        else
          new_icon.image = nil
        end
        new_icon.save!
        icons_hash[icon.id] = new_icon.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      Graphic.where(decision_aid_id: @decision_aid_id).each do |graphic|
        graphic_attrs = graphic.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_graphic = Graphic.cross_clone_hash(graphic_attrs)
        new_graphic.decision_aid_id = new_da.id
        new_graphic.save!
        graphics_hash[graphic.id] = new_graphic.id
      end

      old_latent_class_ids = []
      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      LatentClass.where(decision_aid_id: @decision_aid_id).each do |lc|
        lc_attrs = lc.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_lc = LatentClass.cross_clone_hash(lc_attrs)
        new_lc.decision_aid_id = new_da.id
        new_lc.save!
        latent_classes_hash[lc.id] = new_lc.id
        old_latent_class_ids << lc.id
      end

      if old_latent_class_ids.length > 0
        if @diff_connections
          ActiveRecord::Base.establish_connection @source_connection_hash
        end
        LatentClassOption.where(latent_class_id: old_latent_class_ids).each do |lco|
          lco_attrs = lco.attributes
          if @diff_connections
            ActiveRecord::Base.establish_connection @dest_connection_hash
          end
          new_lco = LatentClassOption.cross_clone_hash(lco_attrs)
          new_lco.latent_class_id = latent_classes_hash[lco.latent_class_id]
          new_lco.option_id = options_hash[lco.option_id]
          new_lco.save!
          latent_class_options_hash[lco.id] = new_lco.id
        end

        if @diff_connections
          ActiveRecord::Base.establish_connection @source_connection_hash
        end
        LatentClassProperty.where(latent_class_id: old_latent_class_ids).each do |lcp|
          lcp_attrs = lcp.attributes
          if @diff_connections
            ActiveRecord::Base.establish_connection @dest_connection_hash
          end
          new_lcp = LatentClassProperty.cross_clone_hash(lcp_attrs)
          new_lcp.latent_class_id = latent_classes_hash[lcp.latent_class_id]
          new_lcp.property_id = properties_hash[lcp.property_id]
          new_lcp.save!
          latent_class_options_hash[lcp.id] = new_lcp.id
        end
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      Accordion.where(decision_aid_id: @decision_aid_id).each do |ac|
        ac_attrs = ac.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_ac = Accordion.cross_clone_hash(ac_attrs)
        new_ac.decision_aid_id = new_da.id
        new_ac.save!
        accordions_hash[ac.id] = new_ac.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      AccordionContent.where(decision_aid_id: @decision_aid_id).each do |acc|
        acc_attrs = acc.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_acc = AccordionContent.cross_clone_hash(acc_attrs)
        new_acc.decision_aid_id = new_da.id
        new_acc.accordion_id = accordions_hash[acc.accordion_id]
        new_acc.save!
        accordion_contents_hash[acc.id] = new_acc.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      NavLink.where(decision_aid_id: @decision_aid_id).each do |nl|
        nl_attrs = nl.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_nl = NavLink.cross_clone_hash(nl_attrs)
        new_nl.decision_aid_id = new_da.id
        new_nl.save!
        nav_links_hash[nl.id] = new_nl.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      SkipLogicTarget.where(decision_aid_id: @decision_aid_id).each do |slt|
        slt_attrs = slt.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_slt = SkipLogicTarget.cross_clone_hash(slt_attrs)

        if slt.skip_question_page_id
          new_slt.skip_question_page_id = question_pages_hash[slt.skip_question_page_id]
        end
        if slt.question_page_id
          new_slt.question_page_id = question_pages_hash[slt.question_page_id]
        end
        if slt.question_response_id
          new_slt.question_response_id = question_responses_hash[slt.question_response_id]
        end
        if slt.skip_page_url
          new_slt.skip_page_url = slt.skip_page_url.gsub("/decision_aid/#{@decision_aid.slug}/", "/decision_aid/#{new_da.slug}/")
        end
        new_slt.decision_aid_id = new_da.id

        new_slt.save!
        skip_logic_targets_hash[slt.id] = new_slt.id
      end

      if @diff_connections
        ActiveRecord::Base.establish_connection @source_connection_hash
      end
      SkipLogicCondition.where(decision_aid_id: @decision_aid_id).each do |slc|
        slc_attrs = slc.attributes
        if @diff_connections
          ActiveRecord::Base.establish_connection @dest_connection_hash
        end
        new_slc = SkipLogicCondition.cross_clone_hash(slc_attrs)

        # TODO: special cases depending on condition_entity
        if slc.condition_entity == "question_response"
          if slc.entity_lookup and 
             slc.value_to_match and 
             questions_hash[slc.entity_lookup.to_i] and 
             question_responses_hash[slc.value_to_match.to_i]

            new_slc.entity_lookup = questions_hash[slc.entity_lookup.to_i].to_s
            new_slc.value_to_match = question_responses_hash[slc.value_to_match.to_i].to_s
          end
        end

        new_slc.decision_aid_id = new_da.id
        new_slc.skip_logic_target_id = skip_logic_targets_hash[slc.skip_logic_target_id]

        new_slc.save!
        skip_logic_conditions_hash[slc.id] = new_slc.id
      end

      # update all references

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
        if OptionProperty.exists?(id: value)
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
          a.response_value_calculation = a.response_value_calculation.gsub(QUESTION_CALC_REGEX) do |match|
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

      summary_pages_hash.each do |key, value|
        a = SummaryPage.find(value)
        if SummaryPage.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          SummaryPage::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if SummaryPage.const_defined? :INJECTABLE_ATTRIBUTES
          SummaryPage::INJECTABLE_ATTRIBUTES.each do |it|
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

      static_pages_hash.each do |key, value|
        a = StaticPage.find(value)
        if StaticPage.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          StaticPage::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if StaticPage.const_defined? :INJECTABLE_ATTRIBUTES
          StaticPage::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      nav_links_hash.each do |key, value|
        a = NavLink.find(value)
        if NavLink.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          NavLink::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if NavLink.const_defined? :INJECTABLE_ATTRIBUTES
          NavLink::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      skip_logic_targets_hash.each do |key, value|
        a = SkipLogicTarget.find(value)
        if SkipLogicTarget.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          SkipLogicTarget::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if SkipLogicTarget.const_defined? :INJECTABLE_ATTRIBUTES
          SkipLogicTarget::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      skip_logic_conditions_hash.each do |key, value|
        a = SkipLogicCondition.find(value)
        if SkipLogicCondition.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          SkipLogicCondition::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if SkipLogicCondition.const_defined? :INJECTABLE_ATTRIBUTES
          SkipLogicCondition::INJECTABLE_ATTRIBUTES.each do |it|
            update_injectable_attribute_refs(a, it, questions_hash)
          end
        end
        a.save!
      end

      accordion_contents_hash.each do |key, value|
        a = AccordionContent.find(value)
        if AccordionContent.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
          AccordionContent::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
            update_has_attached_item_refs(a, it, accordions_hash, graphics_hash)
          end
        end
        if AccordionContent.const_defined? :INJECTABLE_ATTRIBUTES
          AccordionContent::INJECTABLE_ATTRIBUTES.each do |it|
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

      new_da.icon_id = icons_hash[@decision_aid.icon_id]
      new_da.save!
    end

    # transaction finished, now fix counts
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
    SummaryPage.counter_culture_fix_counts
    StaticPage.counter_culture_fix_counts
    NavLink.counter_culture_fix_counts
    SkipLogicTarget.counter_culture_fix_counts
  end

  private

  def recursively_update_lookup_hash(old_hash, question_responses_hash)
    new_hash = Hash.new
    old_hash.map do |key, value| 
      new_key = question_responses_hash[key.to_i].to_s
      new_hash[new_key] = value.kind_of?(Hash) ? recursively_update_lookup_hash(value, question_responses_hash) : value
      new_hash[new_key] = value.collect{ |obj| recursively_update_lookup_hash(obj, question_responses_hash) if obj.kind_of?(Hash)} if value.kind_of?(Array)
    end
    new_hash
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
      item[atr].gsub!(DecisionAidCloneService::ACCORDION_REGEX) do |match|
        accordion_id = $1.to_i
        if accordions_hash[accordion_id]
          match.gsub("[accordion id=\"#{$1}\"", "[accordion id=\"#{accordions_hash[accordion_id]}\"")
        else
          match
        end
      end
    end
    if item[atr]
      item[atr].gsub!(DecisionAidCloneService::GRAPHIC_REGEX) do |match|
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
    unpublished_atr = atr.to_s.gsub('_published', '').to_sym
    if item[unpublished_atr]
      item[unpublished_atr].gsub!(DecisionAidCloneService::INJECTABLE_REGEX) do |match|
        question_id = $2.to_i
        if questions_hash[question_id]
          match.gsub("[question id=#{$1}#{$2}", "[question id=#{$1}#{questions_hash[question_id]}")
        else
          match
        end
      end
    else
      if item[atr]
        item[atr].gsub!(DecisionAidCloneService::INJECTABLE_REGEX) do |match|
          question_id = $2.to_i
          if questions_hash[question_id]
            match.gsub("[question id=#{$1}#{$2}", "[question id=#{$1}#{questions_hash[question_id]}")
          else
            match
          end
        end
      end
    #end
  end

  def copy_accordions(creator, ach, acch)
    accordions = Accordion.where(user_id: creator)
    accordions.each do |a|
      new_a = a.dup
      new_a.save!
      ach[a.id] = new_a.id

      acs = AccordionContent.where(accordion_id: a.id)
      acs.each do |ac|
        new_ac = ac.dup
        new_ac.accordion_id = new_a.id
        new_ac.save!
        acch[ac.id] = new_ac.id
      end
    end
  end
end