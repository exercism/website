module Badges
  class BardBadge < Badge
    seed "Bard",
      :legendary,
      'bard',
      'Created an exercise story'

    def award_to?(user)
      return false unless user.github_username

      BARDS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition? = true

    BARDS = %w[
      aldraco
      andrerfcsantos
      andres-zartab
      angelikatyborska
      archrisv
      bethanyg
      brugnara
      ceddlyburge
      chocopowwwa
      cmcaine
      coriolinus
      efx
      erikschierboom
      gilescope
      glennj
      ihid
      isaacg
      itamargal
      j08k
      jamessouth
      japatgithub
      jiegillet
      jmrunkle
      junedev
      kimolivia
      kristinaborn
      lewisclement
      limm-jk
      lxmrc
      maurelio1234
      meatball
      micuffaro
      mikedamay
      mohanrajanr
      mpizenberg
      neenjaw
      nikimanoledaki
      omega-y
      ovidiu141
      pault89
      peterchu999
      pranasziaukas
      pvcarrera
      rishiosaur
      sachsom95
      saschamann
      seanchen1991
      senal
      shubhsk88
      sleeplessbyte
      stargator
      still-flow
      sudomateo
      talesdias
      tehsphinx
      thelostlambda
      ticktakto
      tompradat
      vaeng
      valentin-p
      verdammelt
      wneumann
      wnstj2007
      yabby1997
      yyyc514
      yzalvin
    ].freeze
    private_constant :BARDS
  end
end
