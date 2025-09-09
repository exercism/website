class Localization::GlossaryEntryProposal < ApplicationRecord
  disable_sti!

  belongs_to :glossary_entry, optional: true
  belongs_to :proposer, class_name: 'User'
  belongs_to :reviewer, class_name: 'User', optional: true

  enum type: {
    addition: 1,
    modification: 2,
    deletion: 3
  }

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def type = super.to_sym
  def status = super.to_sym
  def to_param = uuid
  def locale = super || glossary_entry&.locale
  def term = super || glossary_entry&.term
  def llm_instructions = super || glossary_entry&.llm_instructions
end
