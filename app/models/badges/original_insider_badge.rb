module Badges
  class OriginalInsiderBadge < Badge
    seed "Original Insider",
      :legendary,
      'original-insider',
      'One of the Original Insiders'

    def award_to?(user)
      ORIGINAL_INSIDER_HANDLES.include?(user.handle.downcase)
    end

    def send_email_on_acquisition? = true

    # TODO: update original insider handles just before launching
    ORIGINAL_INSIDER_HANDLES = %w[kytrinyx ihid erikschierboom].freeze
    private_constant :ORIGINAL_INSIDER_HANDLES
  end
end
