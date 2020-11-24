# == Schema Information
#
# Table name: progress_trackers
#
#  id                   :integer          not null, primary key
#  decision_aid_user_id :integer
#

class ProgressTracker < ApplicationRecord

  after_create :initialize_section_trackers

  has_many :section_trackers, dependent: :destroy
  belongs_to :decision_aid_user

  def calculate_progress(decision_aid)
    last_section_complete = true
    page_hash = Hash.new
    skip_section_target = nil
    skipping = false

    section_trackers.ordered.includes(:sub_decision).each_with_index do |st, ind|
      page_constants = st.constants_for_page(decision_aid)
      page_hash[page_constants[:key]] = Hash.new
      #puts "\n\n\n\n\n"
      #puts page_constants
      if page_constants[:kn] == skip_section_target
        skipping = false
        skip_section_target = nil
      end

      section_complete = (last_section_complete ? st.is_complete(decision_aid, self.decision_aid_user) : false)

      if !last_section_complete
        page_hash[page_constants[:key]][:available] = false
        page_hash[page_constants[:key]][:completed] = false
      else
        page_hash[page_constants[:key]][:available] = last_section_complete
        page_hash[page_constants[:key]][:completed] = section_complete
      end
      page_hash[page_constants[:key]][:page_title] = page_constants[:page_title]
      page_hash[page_constants[:key]][:page_name] = page_constants[:page_name]
      page_hash[page_constants[:key]][:page_params] = page_constants[:page_params]
      page_hash[page_constants[:key]][:kn] = page_constants[:kn]
      page_hash[page_constants[:key]][:key] = page_constants[:key]
      page_hash[page_constants[:key]][:page_index] = ind

      page_hash[page_constants[:key]][:skipped] = skipping

      if skipping
        page_hash[page_constants[:key]][:available] = true
        page_hash[page_constants[:key]][:completed] = true
        section_complete = true
      end

      last_section_complete = section_complete

      if st.skip_section_target
        skipping = true
        skip_section_target = st.skip_section_target
      end
    end
    page_hash
  end

  private

  def initialize_section_trackers
    da = self.decision_aid_user.decision_aid
    #puts "\n\n\n#{da.inspect}\n\n\n"
    SectionTracker::init_for_decision_aid(da, self.id)
  end
end
