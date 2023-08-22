require "test_helper"

class Badge::ResearcherBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :researcher_badge
    assert_equal "Researcher", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :researcher, badge.icon
    assert_equal 'Helped develop Exercism Research', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    badge = create :researcher_badge

    non_researcher_user = create :user
    refute badge.award_to?(non_researcher_user)

    non_github_user = create :user, github_username: nil
    refute badge.award_to?(non_github_user)

    # Checks username case-insensitive
    %w[erikschierboom ERIKSCHIERBOOM ErikSchierboom].each do |github_username|
      user = create(:user, github_username:)
      assert badge.award_to?(user)
      user.destroy
    end

    %w[
      bergjohan
      bkhl
      bubo-py
      ceddlyburge
      coriolinus
      ee7
      ErikSchierboom
      goalaleo
      iHiD
      kntsoriano
      kytrinyx
      mmmmmrob
      mpizenberg
      nicolechalmers
      pvcarrera
      SleeplessByte
      sshine
      tehsphinx
      TheLostLambda
      yawpitch
    ].each do |github_username|
      researcher_user = create(:user, github_username:)

      # Award to researcher user
      assert badge.award_to?(researcher_user)
    end
  end
end
