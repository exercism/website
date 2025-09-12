class Localization::GlossaryEntry < ApplicationRecord
  enum :status, {
    generating: 0,
    unchecked: 1,
    proposed: 2,
    checked: 3
  }

  has_many :proposals, class_name: "Localization::GlossaryEntryProposal", dependent: :destroy

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
    self.status = :unchecked if status.blank?
  end

  def to_param = uuid
  def status = super.to_sym
end
