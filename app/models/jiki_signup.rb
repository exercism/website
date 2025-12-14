class JikiSignup < ApplicationRecord
  belongs_to :user

  validates :preferred_locale, presence: true
  validates :preferred_programming_language, presence: true, inclusion: { in: %w[javascript python either] }

  PROGRAMMING_LANGUAGES = [
    ["No preference", "either"],
    %w[Python python],
    %w[JavaScript javascript]
  ].freeze
end
