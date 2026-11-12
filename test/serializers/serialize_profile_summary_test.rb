require 'test_helper'

class SerializeProfileSummaryTest < ActiveSupport::TestCase
  test "serializes a profile" do
    user = create :user, handle: 'iHiD', name: 'Jeremy Walker', location: 'Bree',
      pronouns: 'he/him', bio: 'Hello', reputation: 50
    create :user_profile, user:, github: 'iHiD', twitter: 'iHiD', website: 'https://ihid.info'
    ruby = create :track, slug: 'ruby', title: 'Ruby'
    go = create :track, slug: 'go', title: 'Go'
    create :user_reputation_period, user:, about: :track, track_id: go.id, reputation: 10
    create :user_reputation_period, user:, about: :track, track_id: ruby.id, reputation: 40
    acquired_badge = create(:user_acquired_badge, user:, revealed: true)

    expected = {
      handle: 'iHiD',
      name: 'Jeremy Walker',
      url: Exercism::Routes.profile_url(user),
      avatar_url: user.avatar_url,
      flair: nil,
      location: 'Bree',
      pronouns: 'he/him',
      bio: 'Hello',
      joined_at: user.created_at.iso8601,
      reputation: 50,
      top_tracks: [
        { slug: 'ruby', title: 'Ruby', reputation: 40 },
        { slug: 'go', title: 'Go', reputation: 10 }
      ],
      num_published_solutions: 0,
      num_published_testimonials: 0,
      num_badges: 1,
      featured_badges: [{ name: acquired_badge.badge.name, rarity: acquired_badge.badge.rarity }],
      links: {
        github: 'https://github.com/iHiD',
        twitter: 'https://twitter.com/iHiD',
        website: 'https://ihid.info'
      }
    }

    assert_equal expected, SerializeProfileSummary.(user)
  end

  test "omits blank fields" do
    user = create :user, location: '', pronouns: nil, bio: nil
    create(:user_profile, user:)

    summary = SerializeProfileSummary.(user)

    assert_nil summary[:location]
    assert_nil summary[:pronouns]
    assert_nil summary[:bio]
    assert_empty summary[:top_tracks]
    assert_empty summary[:featured_badges]
    assert_empty summary[:links]
  end
end
