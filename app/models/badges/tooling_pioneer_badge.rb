module Badges
  class ToolingPioneerBadge < Badge
    seed "Tooling Pioneer",
      :legendary,
      'tooling-pioneer',
      'Developed early prototypes of tooling for Exercism'

    def award_to?(user)
      return false unless user.github_username

      PIONEERS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition? = true

    PIONEERS = %w[
      alirezaghey
      bergjohan
      ceddlyburge
      cmccandless
      coriolinus
      erikschierboom
      ihid
      mpizenberg
      seventhnadir
      sleeplessbyte
      tehsphinx
      thelostlambda
      yawpitch
    ].freeze
    private_constant :PIONEERS
  end
end
