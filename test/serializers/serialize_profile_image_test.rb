require 'test_helper'

class SerializeProfileImageTest < ActiveSupport::TestCase
  test "serializes everything needed to draw the image" do
    user = create :user, handle: 'ihid', name: 'Jeremy Walker', flair: :founder
    create(:user_profile, user:)

    actual = SerializeProfileImage.(user)

    assert_equal 'ihid', actual[:header][:handle]
    assert_equal 'Jeremy Walker', actual[:header][:name]
    assert_equal user.avatar_url, actual[:header][:avatar_url]
    assert actual[:header][:avatar_data].start_with?("data:image/png;base64,")
    assert_equal user.reputation, actual[:header][:reputation]
    assert_equal :founder, actual[:header][:flair]
  end

  test "inlines an external avatar_url too, so the generator never fetches" do
    # No attachment, just a GitHub URL. Rails fetches it and inlines the bytes,
    # so the generator's Lambda never egresses through the NAT.
    user = create :user, :external_avatar_url
    create(:user_profile, user:)
    stub_request(:get, user.attributes['avatar_url']).to_return(
      body: File.binread(Rails.root.join("app", "images", "favicon.png")),
      headers: { 'Content-Type' => 'image/png' }
    )

    actual = SerializeProfileImage.(user)

    assert actual[:header][:avatar_data].start_with?("data:image/png;base64,")
    assert_equal user.avatar_url, actual[:header][:avatar_url]
  end

  # A missing or reordered category silently rotates the chart away from its labels.
  test "serializes all six categories in the order the chart assumes" do
    user = create :user
    create(:user_profile, user:)

    actual = SerializeProfileImage.(user)

    assert_equal(%i[publishing mentoring authoring building maintaining other],
      actual[:categories].map { |category| category[:id] })
    assert(actual[:categories].all? { |category| category[:reputation].present? || category[:reputation].zero? })
  end

  test "uses the full metric rather than the short one" do
    user = create :user
    create(:user_profile, user:)
    create(:user_published_solution_reputation_token, user:)

    actual = SerializeProfileImage.(user)
    publishing = actual[:categories].find { |category| category[:id] == :publishing }

    assert_equal "1 solution published", publishing[:metric]
  end

  test "sends each badge's icon and rarity" do
    user = create :user
    create(:user_profile, user:)
    badge = create(:moss_badge)
    create(:user_acquired_badge, user:, badge:, revealed: true)

    actual = SerializeProfileImage.(user)

    assert_equal [{ icon: :moss, rarity: :legendary }], actual[:header][:badges]
  end

  test "sends at most five badges, rarest first" do
    user = create :user
    create(:user_profile, user:)
    [
      create(:rookie_badge), create(:member_badge), create(:all_your_base_badge),
      create(:lackadaisical_badge), create(:begetter_badge), create(:moss_badge)
    ].each { |badge| create(:user_acquired_badge, user:, badge:, revealed: true) }

    actual = SerializeProfileImage.(user)

    assert_equal 5, actual[:header][:badges].size
    assert_equal(%i[legendary legendary ultimate rare common],
      actual[:header][:badges].map { |badge| badge[:rarity] })
  end

  # An unrevealed badge mustn't be spoiled by a public share image.
  test "ignores unrevealed badges" do
    user = create :user
    create(:user_profile, user:)
    create(:user_acquired_badge, user:, badge: create(:moss_badge), revealed: false)

    actual = SerializeProfileImage.(user)

    assert_empty actual[:header][:badges]
  end

  test "founder takes precedence over the other tags" do
    user = create :user, :founder, :maintainer
    create(:user_profile, user:)

    actual = SerializeProfileImage.(user)

    assert_equal ["Exercism Founder"], actual[:header][:tags]
  end

  test "sends the other tags, capped at two" do
    user = create :user, :staff, :maintainer
    create(:user_profile, user:)

    actual = SerializeProfileImage.(user)

    assert_equal ["Exercism Staff", "Maintainer"], actual[:header][:tags]
  end

  test "sends no tags for an ordinary user" do
    user = create :user
    create(:user_profile, user:)

    actual = SerializeProfileImage.(user)

    assert_empty actual[:header][:tags]
  end

  test "serializes a brand new profile" do
    user = create :user, name: nil
    create(:user_profile, user:)

    actual = SerializeProfileImage.(user)

    assert_nil actual[:header][:flair]
    assert_empty actual[:header][:badges]
    assert_equal 6, actual[:categories].size
  end
end
