module Badges
  class BegetterBadge < Badge
    seed "Begetter",
      :legendary,
      'begetter',
      'Significantly contributed to a Track before launch'

    def award_to?(user)
      return false unless user.github_username

      BEGETTERS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition? = true

    BEGETTERS = %w[
      aarti
      alexanderific
      amscotti
      andrej-makarov-skrt
      arguello
      axtens
      bdw429s
      berg-johan
      bressain
      bushidocodes
      canweriotnow
      chezwicker
      clementi
      cmc333333
      derekgottlieb
      dispader
      dog
      elorest
      erikschierboom
      etrepum
      glennj
      hankturowski
      icyrockcom
      jonboiser
      joshgoebel
      jrdnull
      jwood803
      kenden
      kytrinyx
      larshp
      leavenha
      legalizeadulthood
      lpil
      macta
      marianfoo
      mbertheau
      mbtools
      mhelmetag
      mhinz
      mikegehard
      ozan
      paf31
      parkerl
      pclausen
      pminten
      pokrakam
      porkostomus
      qjd2413
      robinhilliard
      rpottsoh
      rubysolo
      saschamann
      sdavids13
      sgrif
      sillymoose
      sit
      sjakobi
      sleeplessbyte
      sshine
      stevejb71
      sunzenshen
      superpaintman
      szabgab
      tgecho
      thelostlambda
      tmcgilchrist
      verdammelt
    ].freeze
    private_constant :BEGETTERS
  end
end
