module Badges
  class ResearcherBadge < Badge
    seed "Researcher",
      :legendary,
      'researcher',
      'Helped develop Exercism Research'

    def award_to?(user)
      return false unless user.github_username

      RESEARCHERS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition? = true

    RESEARCHERS = %w[
      bergjohan
      bkhl
      bubo-py
      ceddlyburge
      coriolinus
      ee7
      erikschierboom
      goalaleo
      ihid
      kntsoriano
      kytrinyx
      mmmmmrob
      mpizenberg
      nicolechalmers
      pvcarrera
      sleeplessbyte
      sshine
      tehsphinx
      thelostlambda
      yawpitch
    ].freeze
    private_constant :RESEARCHERS
  end
end
