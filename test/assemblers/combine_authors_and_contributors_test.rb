require 'test_helper'

class CombineAuthorsAndContributorsTest < ActiveSupport::TestCase
  test "uses authors up to limit" do
    users = create_list(:user, 6)
    authors = User.where('id < ?', users[5].id)
    contributors = User.where('id >= ?', users[5].id)

    combination = CombineAuthorsAndContributors.(authors, contributors, limit: 3)

    assert_equal 3, combination.count
    assert_equal combination, combination & authors
    assert_empty combination & contributors
  end

  test "uses contributors to pad authors to limit" do
    users = create_list(:user, 6)
    authors = User.where('id < ?', users[2].id)
    contributors = User.where('id >= ?', users[2].id)

    combination = CombineAuthorsAndContributors.(authors, contributors, limit: 3)

    assert_equal 3, combination.count
    assert_equal combination[0..1], combination[0..1] & authors
    assert_equal combination[2..], combination[2..] & contributors
  end

  test "uses contributors if there are no authors" do
    create_list(:user, 6)
    authors = User.none
    contributors = User.all

    combination = CombineAuthorsAndContributors.(authors, contributors, limit: 3)

    assert_equal 3, combination.count
    assert_empty combination & authors
    assert_equal combination, combination & contributors
  end

  test "default limit is set to 3" do
    users = create_list(:user, 6)
    authors = User.where('id < ?', users[5].id)
    contributors = User.where('id >= ?', users[5].id)

    combination = CombineAuthorsAndContributors.(authors, contributors)

    assert_equal 3, combination.count
  end

  test "support non-user table via user_id_column" do
    track = create :track

    users = create_list(:user, 6) do |user|
      create(:user_track, user:, track:)
    end

    authors = User.where('id < ?', users[5].id)
    contributors = User.where('id >= ?', users[5].id)

    authors_via_user_track = UserTrack.where('user_id < ?', users[5].id)
    contributors_via_user_track = UserTrack.where('user_id >= ?', users[5].id)

    combination = CombineAuthorsAndContributors.(
      authors_via_user_track,
      contributors_via_user_track,
      limit: 3,
      user_id_column: :user_id
    )

    assert_equal 3, combination.count
    assert_equal combination, combination & authors
    assert_empty combination & contributors
  end

  test "supports arrays" do
    users = create_list(:user, 6)
    authors = users[0..1]
    contributors = users[2..]

    combination = CombineAuthorsAndContributors.(authors, contributors, limit: 3)

    assert_equal combination[0..1], combination[0..1] & authors
    assert_equal combination[2..], combination[2..] & contributors
  end
end
