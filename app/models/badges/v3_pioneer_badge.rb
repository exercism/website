module Badges
  class V3PioneerBadge < Badge
    seed "V3 Pioneer",
      :ultimate,
      'v3-pioneer',
      'Awarded for having helped build Exercism version 3'

    def award_to?(user)
      V3_PIONEERS.include?(user.handle)
    end

    def send_email_on_acquisition?
      false
    end

    V3_PIONEERS = %w[
      aes421
      aimorris
      AlbusPortucalis
      aldraco
      AlexLeSang
      andrerfcsantos
      andres-zartab
      angelikatyborska
      archrisV
      Azumix
      batibot323
      bemself
      ben-grossmann
      benreyn
      bergjohan
      BethanyG
      bgottlob
      biancapower
      bkhl
      bmeverett
      bobahop
      Br1ght0ne
      Calamari
      ceddlyburge
      chocopowwwa
      cmcaine
      cmccandless
      Cohen-Carlisle
      Corentin-Leffy
      coriolinus
      cstby
      DavidGerva
      DavyJ0nes
      dector
      devanshraj300
      devkabiir
      dvik1950
      ee7
      efx
      eparovyshnaya
      EQt
      ericbalawejder
      ErikSchierboom
      eroStun
      evelynstender
      ferhatelmas
      fireproofsocks
      gilescope
      goalaleo
      HanaisMe
      hans-d
      HaoZeke
      haunshila
      hayashi-ay
      himanshugoyal1065
      iHiD
      InfiniteVerma
      isaac
      itamargal
      J08K
      jamessouth
      jiegillet
      Jlamon
      jmrunkle
      jocelo
      jonathanyeong
      jonmcalder
      joshgoebel
      joshiraez
      jrr
      junedev
      jwarwick
      kayn1
      KevinWMatthews
      khoivan88
      kimolivia
      kmjones77
      kotp
      kristinaborn
      kytrinyx
      leobenkel
      lewisclement
      Limm-jk
      lxmrc
      m-dango
      maurelio1234
      mayurdw
      mcaci
      micuffaro
      miguelraz
      mikedamay
      mirkoperillo
      mohanrajanr
      morrme
      mpizenberg
      mrvlous
      msomji
      nathanchere
      neenjaw
      neiesc
      NextNebula
      nicolechalmers
      nikimanoledaki
      NobbZ
      nov314k
      ntsoriano
      oanaOM
      OMEGA-Y
      ovidiu141
      paparomeo
      patricksjackson
      pdmoore
      peterchu999
      porkostomus
      pranasziaukas
      proose
      Prounckk
      pvcarrera
      pwadsworth
      pyropy
      rcardenes
      rfilipo
      ricemery
      rishiosaur
      robkeim
      rpottsoh
      ryanplusplus
      sachsom95
      samuelteixeiras
      samWson
      SaschaMann
      seanchen1991
      sebito91
      senal
      serenalucca
      sgedye
      shaynuhcon
      shubhsk88
      siebenschlaefer
      silvanocerza
      SleeplessByte
      sshine
      Stargator
      Syntax753
      taiyab
      TalesDias
      tehsphinx
      TheLostLambda
      thodg
      Ticktakto
      timotheosh
      tushartyagi
      uzilan
      valentin-p
      verdammelt
      wneumann
      wnstj2007
      wolf99
      workingjubilee
      Yabby1997
      yawpitch
      ynfle
      ystromm
      ZoltanOnody
      Zulu-Inuoe
      zuzia-kru
    ].freeze
    private_constant :V3_PIONEERS
  end
end
