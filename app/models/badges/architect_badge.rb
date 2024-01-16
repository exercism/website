module Badges
  class ArchitectBadge < Badge
    seed "Architect",
      :legendary,
      'architect',
      'Designed a track syllabus'

    def award_to?(user)
      return false unless user.github_username

      ARCHITECTS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition? = true

    ARCHITECTS = %w[
      angelikatyborska
      bethanyg
      ceddlyburge
      coriolinus
      davidgerva
      efx
      erikschierboom
      glennj
      junedev
      meatball
      mikedamay
      mirkoperillo
      mpizenberg
      neenjaw
      porkostomus
      sleeplessbyte
      thelostlambda
      vaeng
      verdammelt
      wneumann
      yawpitch
    ].freeze
    private_constant :ARCHITECTS
  end
end
