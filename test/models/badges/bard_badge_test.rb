require "test_helper"

class Badge::BardBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :bard_badge
    assert_equal "Bard", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :bard, badge.icon
    assert_equal 'Created an exercise story', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award to bard user" do
    badge = create :bard_badge

    %w[
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
      valentin-p
      verdammelt
      wneumann
      wnstj2007
      yabby1997
      yyyc514
      yzalvin
    ].each do |github_username|
      bard_user = create(:user, github_username:)
      assert badge.award_to?(bard_user)
    end
  end

  test "award to bard user case-insensitive" do
    badge = create :bard_badge

    # Checks username case-insensitive
    %w[erikschierboom ERIKSCHIERBOOM ErikSchierboom].each do |github_username|
      user = create(:user, github_username:)
      assert badge.award_to?(user)
      user.destroy
    end
  end

  test "don't award to non-bard user" do
    badge = create :bard_badge

    non_pioneer_user = create :user
    refute badge.award_to?(non_pioneer_user)
  end

  test "don't award to non-github user" do
    badge = create :bard_badge

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)
  end
end
