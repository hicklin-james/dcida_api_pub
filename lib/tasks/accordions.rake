ACCORDION_REGEX = /\[accordion id="([0-9]+)"\]/

namespace :accordions do
  task migrateToDecisionAidReference: :environment do
    ActiveRecord::Base.transaction do
      aors = AccordionObjectReference.where.not(object_type: 'AccordionContent')
        #.order("(CASE WHEN accordion_object_references.object_type = 'AccordionContent' THEN 1 ELSE 0 END) ASC")
    
      original_accordion_ids = []
      accordion_old_new_map = Hash.new
      accordion_content_old_new_map = Hash.new
      copied_to_decision_aid = Hash.new

      aors.each do |aor|
        accordion = Accordion.find_by(id: aor.accordion_id)
        if accordion
          original_accordion_ids << accordion.id
          duped_accordion = accordion.dup
          duped_accordion.save!
          if !accordion_old_new_map[accordion.id]
            accordion_old_new_map[accordion.id] = Array.new
          end
          contents = accordion.accordion_contents

          contents.each do |ac|
            duped_content = ac.dup
            duped_content.accordion_id = duped_accordion.id
            duped_content.save!
            if !accordion_content_old_new_map[ac.id]
              accordion_content_old_new_map[ac.id] = duped_content
            end
          end

         decision_aid_id = nil

          if aor.object_type == "DecisionAid"
            decision_aid_id = aor.object_id
          else
            obj = aor.object_type.constantize.find_by(id: aor.object_id)
            if obj
              decision_aid_id = obj.decision_aid_id
            end
          end

          if decision_aid_id
            if !copied_to_decision_aid[decision_aid_id]
              copied_to_decision_aid[decision_aid_id] = Hash.new
            end
            
            # check if this accordion has already been copied to this decision aid
            if !copied_to_decision_aid[decision_aid_id][aor.accordion_id]
              duped_accordion.decision_aid_id = decision_aid_id
              duped_accordion.save!
              duped_accordion.accordion_contents.each do |ac|
                ac.decision_aid_id = decision_aid_id
                ac.save!
              end
              accordion_old_new_map[aor.accordion_id] << duped_accordion
              copied_to_decision_aid[decision_aid_id][aor.accordion_id] = duped_accordion
            else
              # use existing duped accordion
              duped_accordion.destroy!
              duped_accordion = copied_to_decision_aid[decision_aid_id][aor.accordion_id]
            end
            
            # update the object to point to this new accordion
            obj = aor.object_type.constantize.find_by(id: aor.object_id)
            if obj
              if aor.object_type.constantize.const_defined? :HAS_ATTACHED_ITEMS_ATTRIBUTES
                aor.object_type.constantize::HAS_ATTACHED_ITEMS_ATTRIBUTES.each do |it|
                  if obj[it]
                    obj[it].gsub!(ACCORDION_REGEX) do |match|
                      accordion_id = $1.to_i
                      if accordion_id && accordion_id == aor.accordion_id
                        match.gsub("[accordion id=\"#{$1}\"", "[accordion id=\"#{duped_accordion.id}\"")
                      else
                       match
                      end
                    end
                  end
                end
              end
              obj.save!
            end
          end
        end
      end

      # now, deal with the nested accordions
      aors = AccordionObjectReference.where(object_type: 'AccordionContent')
      aors.each do |aor|
        parent_accordion_content = AccordionContent.find_by(id: aor.object_id)
        if parent_accordion_content
          parent_accordion = Accordion.find_by(id: parent_accordion_content.accordion_id)
          if parent_accordion
            original_accordion_ids << parent_accordion.id
            if accordion_old_new_map[parent_accordion.id] && accordion_old_new_map[parent_accordion.id].length > 0
              accordion_old_new_map[parent_accordion.id].each do |new_parent|
                puts "New parent decision aid: #{new_parent.decision_aid_id}"
                child = nil
                if accordion_old_new_map[aor.accordion_id] && accordion_old_new_map[aor.accordion_id].length > 0
                  puts "This accordion is both a child and a parent. Find duped in parents..."
                  #puts "child accordion found with decision aid ids: #{accordion_old_new_map[aor.accordion_id].map(&:decision_aid_id).to_s}"
                  child = accordion_old_new_map[aor.accordion_id].find {|ac| ac.decision_aid_id == new_parent.decision_aid_id }
                  puts "child is: #{child.to_s}"
                end
                if !child
                  puts "This accordion is just a child - dupe it"
                  ac = Accordion.find_by(id: aor.accordion_id)
                  if ac
                    child = ac.dup
                    child.decision_aid_id = new_parent.decision_aid_id
                    child.save!
                    puts "child is: #{child.to_s}"
                    ac.accordion_contents.each do |acc|
                      new_acc = acc.dup
                      new_acc.decision_aid_id = child.decision_aid_id
                      new_acc.accordion_id = child.id
                      new_acc.save!
                    end
                  end
                end
                if child
                  new_parent.accordion_contents.each do |acc|
                    acc.content.gsub!(ACCORDION_REGEX) do |match|
                      accordion_id = $1.to_i
                      if accordion_id && accordion_id == aor.accordion_id
                        match.gsub("[accordion id=\"#{$1}\"", "[accordion id=\"#{child.id}\"")
                      else
                       match
                      end
                    end
                    acc.save!
                  end
                end
              end
            end
          end
        end
      end

      # Finally, delete old accordions
      # Accordion.where(id: original_accordion_ids.uniq).destroy_all

      # Do some general cleanup
      AccordionObjectReference.all.each do |aor|
        if !Accordion.exists?(id: aor.accordion_id)
          aor.destroy!
        elsif !aor.object_type.constantize.exists?(id: aor.object_id)
          aor.destroy!
        end
      end

      # Now, there are a few accordions left around with no decision aid id
      # keep them in case someone needs them - I can restore them manually!
    end
  end
end
