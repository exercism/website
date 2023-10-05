require "test_helper"

class Badge::ArchitectBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :architect_badge
    assert_equal 'Architect', badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :architect, badge.icon
    assert_equal 'Designed a track syllabus', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award to architect user" do
    badge = create :architect_badge

    %w[
      angelikatyborska
      BethanyG
      ceddlyburge
      coriolinus
      davidgerva
      efx
      erikschierboom
      glennj
      junedev
      mikedamay
      mirkoperillo
      mpizenberg
      neenjaw
      porkostomus
      SleeplessByte
      theLostLambda
      Verdammelt
      wneumann
      yawpitch
    ].each do |github_username|
      architect_user = create(:user, github_username:)
      assert badge.award_to?(architect_user)
    end
  end

  test "award to architect user case-insensitive" do
    badge = create :architect_badge

    # Checks username case-insensitive
    %w[erikschierboom ERIKSCHIERBOOM ErikSchierboom].each do |github_username|
      user = create(:user, github_username:)
      assert badge.award_to?(user)
      user.destroy
    end
  end

  test "don't award to non-architect user" do
    badge = create :architect_badge

    non_architect_user = create :user
    refute badge.award_to?(non_architect_user)
  end

  test "don't award to non-github user" do
    badge = create :architect_badge

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)
  end
end
