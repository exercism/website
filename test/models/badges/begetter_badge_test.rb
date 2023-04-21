require "test_helper"

class Badge::BegetterBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :begetter_badge
    assert_equal 'Begetter', badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :begetter, badge.icon
    assert_equal 'Significantly contributed to a Track before launch', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award to begetter user" do
    badge = create :begetter_badge

    %w[
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
      Dispader
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
      LeaveNhA
      LegalizeAdulthood
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
      SaschaMann
      sdavids13
      sgrif
      sillymoose
      sit
      sjakobi
      sleeplessbyte
      sshine
      stevejb71
      sunzenshen
      SuperPaintman
      szabgab
      tgecho
      thelostlambda
      tmcgilchrist
      verdammelt
    ].each do |github_username|
      begetter_user = create(:user, github_username:)
      assert badge.award_to?(begetter_user)
    end
  end

  test "award to begetter user case-insensitive" do
    badge = create :begetter_badge

    # Checks username case-insensitive
    %w[erikschierboom ERIKSCHIERBOOM ErikSchierboom].each do |github_username|
      user = create(:user, github_username:)
      assert badge.award_to?(user)
      user.destroy
    end
  end

  test "don't award to non-begetter user" do
    badge = create :begetter_badge

    non_begetter_user = create :user
    refute badge.award_to?(non_begetter_user)
  end

  test "don't award to non-github user" do
    badge = create :begetter_badge

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)
  end
end
