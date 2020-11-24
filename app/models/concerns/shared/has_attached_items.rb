module Shared::HasAttachedItems
  extend ActiveSupport::Concern

  ACCORDION_REGEX = /\[accordion id="[0-9]+"\]/
  #GRAPHIC_REGEX = /\[graphic graphic_type="(.*?)"( data="(.*?)")?( selected_index="(.*?)")?( value="[0-9]+")?( max="[0-9]+")?( selected_color="#[0-9a-f]{3,6}")?( unselected_color="#[0-9a-f]{3,6}")?\]/
  #GRAPHIC_REGEX = /\[graphic graphic_type="(.*?)" data="(.*?)"\]/
  GRAPHIC_REGEX = /\[graphic id="[0-9]+"\]/

  module ClassMethods

    # assumes that all attributes have matching column
    # named attribute_published
    def attributes_with_attached_items(attributes)

      # around save allows us to execute some code,
      # yield to the save, and then execute more code.
      # this allows us to use the id AFTER the item has
      # been saved
      around_save :update_published_fields
      after_destroy :delete_object_references

      define_method "delete_object_references" do
        class_name = self.class.name
        AccordionObjectReference.where(object_type: class_name, object_id: self.id).destroy_all
        GraphicObjectReference.where(object_type: class_name, object_id: self.id).destroy_all
      end

      define_method "get_accordion_html" do |accordion|
        accordion_html = "<div><uib-accordion close-others='{{false}}'>"
        accordion.accordion_contents.each do |ac|
          # is-open=\'{{#{ac.is_open_by_default ? ac.is_open_by_default : false}}}\'
          is_open = ac.is_open_by_default ? ac.is_open_by_default : false
          panel_color = ac.panel_color ? 'panel-' + ac.panel_color : 'panel-default'
          accordion_html += "<uib-accordion-group is-open='status.ac_#{ac.id}_open ' panel-class=\'#{panel_color}\' ng-init=\'status.ac_#{ac.id}_open = #{is_open}\'>
                              <uib-accordion-heading>
                                <span class='half-space-right'>
                                  <i ng-class=\"{'fa fa-minus': status.ac_#{ac.id}_open, 'fa fa-plus': !status.ac_#{ac.id}_open }\"></i>
                                </span>
                                #{ac.header}
                              </uib-accordion-heading>
                              #{ac.content_published}
                            </uib-accordion-group>"
        end
        accordion_html += "</uib-accordion></div>"
        accordion_html
      end

      # define_method "update_fields_with_accordion" do |accordion|
      #   attributes.each do |atr|
      #     val = send(atr)
      #     # find the specific accordion that was passed in
      #     this_accordion_regex = /\[accordion id="#{accordion.id}"\]/
      #     val = val.gsub this_accordion_regex do |match|
      #       get_accordion_html(accordion)
      #     end

      #     published_attr = "#{atr.to_s}_published".to_sym
      #     write_attribute published_attr, val
      #   end
      # end

      define_method "update_graphics" do |val, graphic_hash|
        val.gsub GRAPHIC_REGEX do |match|
          # graphic_type = match[/graphic_type="(.*?)"/, 1]
          # value = match[/value="([0-9]+)"/, 1]
          # max = match[/max="([0-9]+)"/, 1]
          # selected_color = match[/selected_color="(#[0-9a-f]{3,6})"/, 1]
          # unselected_color = match[/unselected_color="(#[0-9a-f]{3,6})"/, 1]
          # data = match[/data="(.*?)"/, 1]
          # selected_index = match[/selected_index="(.*?)"/, 1]
          #data = YAML.load(data)
          #g = Graphic.new(graphic_type: graphic_type, value: value, max: max, selected_index: selected_index, selected_color: selected_color, unselected_color: unselected_color, data: data)
          id = /[0-9]+/.match(match).to_s
          if graphic = graphic_hash[id.to_i]
            if html = graphic.specific.graphic_to_html
              html
            else
              "#{match.to_s}&nbsp;<sup class='text-danger'>invalid graphic format</sup>"
            end
          else
            "#{match.to_s}&nbsp;<sup class='text-danger'>invalid graphic format</sup>"
          end
        end
      end

      define_method "update_accordions" do |val, accordion_hash|
        val.gsub ACCORDION_REGEX do |match|
          id = /[0-9]+/.match(match).to_s
          # if accordion doesn't exist - ie. it was deleted, then just leave the tag
          # there but don't render the accordion
          if accordion = accordion_hash[id.to_i]
            get_accordion_html(accordion)
          else
            match.to_s + " (Accordion doesn't exist. Please check that ID is correct)"
          end
        end
      end

      define_method "update_published_fields" do |&block|
        accordion_ids = find_attached_ids(attributes, ACCORDION_REGEX, /[0-9]+/)
        graphic_ids = find_attached_ids(attributes, GRAPHIC_REGEX, /[0-9]+/)

        ActiveRecord::Base.transaction do 
          matched_accordions = Accordion.where(id: accordion_ids.to_a).includes(:accordion_contents)
          accordion_ids = matched_accordions.pluck(:id).uniq
          accordion_hash = matched_accordions.index_by(&:id)
          matched_graphics = Graphic.where(id: graphic_ids.to_a).includes(:graphic_data)
          graphic_ids = matched_graphics.pluck(:id).uniq
          graphic_hash = matched_graphics.index_by(&:id)

          attributes.each do |atr|
            val = send(atr)
            published_attr = "#{atr.to_s}_published".to_sym
            if val
              # accordions
              val = update_accordions(val, accordion_hash)

              # graphics
              val = update_graphics(val, graphic_hash)

              write_attribute published_attr, val
            else
              write_attribute published_attr, nil
            end
          end
        end

        # yield to AR, which saves the record
        block.call

        # After AR has saved, self.id is guaranteed to
        # exist.
        update_accordion_object_references(accordion_ids)
        update_graphic_object_references(graphic_ids)
      end

      define_method "find_attached_ids" do |attributes, regex, inner_regex|
        ids = Set.new
        attributes.each do |atr|
          val = send(atr)
          if val
            val.scan(regex).each do |match|
              id = inner_regex.match(match).to_s.to_i
              ids.add?(id)
            end
          end
        end
        ids
      end

      define_method "update_accordion_object_references" do |found_accordion_ids|
        class_name = self.class.name
        object_references = AccordionObjectReference.where(object_type: class_name, object_id: self.id, accordion_id: found_accordion_ids).pluck(:accordion_id)

        if object_references.length != found_accordion_ids.length
          # get the difference
          new_references = found_accordion_ids.select { |id| !object_references.include?(id) }
          inserts = []
          new_references.each do |ac_id|
            sql_to_insert = "('#{class_name}', '#{Time.now}', '#{Time.now}', #{self.id}, #{ac_id})"
            inserts.push sql_to_insert
          end
          sql = "INSERT INTO accordion_object_references (\"object_type\", \"updated_at\", \"created_at\", \"object_id\", \"accordion_id\") VALUES #{inserts.join(',')}"
          ActiveRecord::Base.connection.execute sql
        end

        AccordionObjectReference.where.not(accordion_id: found_accordion_ids)
                                .where(object_type: class_name, object_id: self.id)
                                .destroy_all
      end

      define_method "update_graphic_object_references" do |found_graphic_ids|
        class_name = self.class.name
        object_references = GraphicObjectReference.where(object_type: class_name, object_id: self.id, graphic_id: found_graphic_ids).pluck(:graphic_id)

        if object_references.length != found_graphic_ids.length
          # get the difference
          new_references = found_graphic_ids.select { |id| !object_references.include?(id) }
          inserts = []
          new_references.each do |ac_id|
            sql_to_insert = "('#{class_name}', '#{Time.now}', '#{Time.now}', #{self.id}, #{ac_id})"
            inserts.push sql_to_insert
          end
          sql = "INSERT INTO graphic_object_references (\"object_type\", \"updated_at\", \"created_at\", \"object_id\", \"graphic_id\") VALUES #{inserts.join(',')}"
          ActiveRecord::Base.connection.execute sql
        end

        # puts "Found graphic ids: #{found_graphic_ids.inspect}"
        # puts "object_type: #{class_name}"
        # puts "object_id: #{self.id.to_s}"
        
        GraphicObjectReference.where.not(graphic_id: found_graphic_ids)
                                .where(object_type: class_name, object_id: self.id)
                                .destroy_all
      end

      private :find_attached_ids
      private :update_accordion_object_references
      private :update_graphic_object_references

    end
  end
end