class Localization::TranslationProposal < ApplicationRecord
  belongs_to :translation
  belongs_to :proposer, class_name: 'User'
  belongs_to :reviewer, class_name: 'User', optional: true

  enum :status, {
    pending: 0,
    accepted: 1,
    rejected: 2
  }

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
  end
end
