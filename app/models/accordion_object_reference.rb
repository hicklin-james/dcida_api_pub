# == Schema Information
#
# Table name: accordion_object_references
#
#  id           :integer          not null, primary key
#  accordion_id :integer
#  object_id    :integer
#  object_type  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AccordionObjectReference < ApplicationRecord
	belongs_to :accordion
end
