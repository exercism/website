class Localization::GlossaryEntry < ApplicationRecord
  has_many :proposals, class_name: "Localization::GlossaryEntryProposal", dependent: :destroy
end
