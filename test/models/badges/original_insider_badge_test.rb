require "test_helper"

class Badge::OriginalInsiderBadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :original_insider_badge
    assert_equal "Original Insider", badge.name
    assert_equal :legendary, badge.rarity
    assert_equal :'original-insider', badge.icon
    assert_equal "One of the Original Insiders", badge.description
    assert badge.send_email_on_acquisition?
  end

  test "award_to?" do
    badge = create :original_insider_badge

    non_original_insider_user = create :user
    refute badge.award_to?(non_original_insider_user)

    # Checks handle case-insensitive
    %w[erikschierboom ERIKSCHIERBOOM ErikSchierboom].each do |handle|
      user = create(:user, handle:)
      assert badge.award_to?(user)
      user.destroy
    end

    # TODO: update original insider handles just before launching
    %w[kytrinyx ihid erikschierboom].each do |handle|
      original_insider_user = create(:user, handle:)
      assert badge.award_to?(original_insider_user)
    end
  end
end
