require "test_helper"

class Badge::V3PioneerBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :v3_pioneer_badge
    assert_equal "V3 Pioneer", badge.name
    assert_equal :ultimate, badge.rarity
    assert_equal :'v3-pioneer', badge.icon # rubocop:disable Naming/VariableNumber
    assert_equal 'Awarded for having helped build Exercism version 3', badge.description
    refute badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    badge = create :v3_pioneer_badge

    non_pioneer_user = create :user
    refute badge.award_to?(non_pioneer_user)

    %w[
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
    ].each do |pioneer|
      pioneer_user = create :user, handle: pioneer

      # Award to pioneer user
      assert badge.award_to?(pioneer_user)
    end
  end
end
