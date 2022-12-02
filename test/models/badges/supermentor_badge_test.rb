require "test_helper"

class Badge::SupermentorBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :supermentor_badge
    assert_equal "Supermentor", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :supermentor, badge.icon
    assert_equal "Mentored 100 students on a track", badge.description
    assert badge.send_email_on_acquisition?
  end

  test "award_to?" do
    user = create :user
    badge = create :supermentor_badge

    # Not a supermentor
    refute badge.award_to?(user.reload)

    # Supermentor
    user.update(roles: [:supermentor])
    assert badge.award_to?(user.reload)
  end
end
