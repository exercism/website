module Badges
  class ResearcherBadge < Badge
    seed "Researcher",
      :ultimate,
      'researcher',
      'Helped with Exercism Research'

    def award_to?(user)
      RESEARCHERS.include?(user.handle.downcase)
    end

    def send_email_on_acquisition?
      true
    end

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
