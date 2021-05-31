require "test_helper"

class User::ReputationPeriod::SearchTest < ActiveSupport::TestCase
  test "no options returns all users that have contributed, ordered by rep" do
    create :user # Never contributed
    big_contributor = create :user, handle: 'big'
    small_contributor = create :user, handle: 'small'
    medium_contributor = create :user, handle: 'medium'

    # Add other contribution rows to ensure they are not counted
    create :user_reputation_period, user: small_contributor, period: :year, reputation: 1000
    create :user_reputation_period, user: small_contributor, about: :track, reputation: 1000
    create :user_reputation_period, user: small_contributor, category: :building, reputation: 1000

    create :user_reputation_period, user: big_contributor, period: :forever, reputation: 50
    create :user_reputation_period, user: small_contributor, period: :forever, reputation: 30
    create :user_reputation_period, user: medium_contributor, period: :forever, reputation: 40

    assert_search [big_contributor, medium_contributor, small_contributor], User::ReputationPeriod::Search.()
  end

  test "handles empty inputs" do
    user = create :user
    create :user_reputation_period, user: user, reputation: 1000

    assert_search [user],
      User::ReputationPeriod::Search.(period: nil, category: nil, track_id: nil, user_handle: nil, page: nil)
    assert_search [user], User::ReputationPeriod::Search.(period: "", category: "", track_id: "", user_handle: "", page: "")
  end

  test "paginates" do
    25.times { create :user_reputation_period }

    first_page = User::ReputationPeriod::Search.()
    assert_equal 20, first_page.limit_value # Sanity

    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = User::ReputationPeriod::Search.(page: 2)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count
  end

  test "filters track correctly" do
    irrelevant_contributor = create :user, handle: 'irrelevant'
    big_contributor = create :user, handle: 'big'
    small_contributor = create :user, handle: 'small'
    medium_contributor = create :user, handle: 'medium'
    track = create :track, slug: :js

    # Add other contribution rows to ensure they are not counted
    create :user_reputation_period, user: small_contributor, period: :forever, reputation: 300

    create :user_reputation_period, user: irrelevant_contributor, period: :forever, reputation: 50, about: :track,
                                    track_id: create(:track).id

    create :user_reputation_period, user: big_contributor, period: :forever, reputation: 50, about: :track,
                                    track_id: track.id
    create :user_reputation_period, user: small_contributor, period: :forever, reputation: 30, about: :track,
                                    track_id: track.id
    create :user_reputation_period, user: medium_contributor, period: :forever, reputation: 40, about: :track,
                                    track_id: track.id

    assert_search [big_contributor, medium_contributor, small_contributor],
      User::ReputationPeriod::Search.(track_id: track.id)
  end

  test "filters period correctly" do
    big_contributor = create :user, handle: 'big'
    small_contributor = create :user, handle: 'small'
    medium_contributor = create :user, handle: 'medium'

    # Add other contribution rows to ensure they are not counted
    create :user_reputation_period, user: small_contributor, period: :forever, reputation: 300

    create :user_reputation_period, user: big_contributor, period: :year, reputation: 50
    create :user_reputation_period, user: small_contributor, period: :year, reputation: 30
    create :user_reputation_period, user: medium_contributor, period: :year, reputation: 40

    assert_search [big_contributor, medium_contributor, small_contributor], User::ReputationPeriod::Search.(period: :year)
  end

  test "filters category correctly" do
    big_contributor = create :user, handle: 'big'
    small_contributor = create :user, handle: 'small'
    medium_contributor = create :user, handle: 'medium'

    # Add other contribution rows to ensure they are not counted
    create :user_reputation_period, user: small_contributor, category: :any, reputation: 300

    create :user_reputation_period, user: big_contributor, category: :maintaining, reputation: 50
    create :user_reputation_period, user: small_contributor, category: :maintaining, reputation: 30
    create :user_reputation_period, user: medium_contributor, category: :maintaining, reputation: 40

    assert_search [big_contributor, medium_contributor, small_contributor],
      User::ReputationPeriod::Search.(category: :maintaining)
  end

  test "filters user_handle correctly" do
    massive_contributor = create :user, handle: 'massive'
    small_contributor = create :user, handle: 'small'
    medium_contributor = create :user, handle: 'medium'

    create :user_reputation_period, user: massive_contributor, reputation: 50
    create :user_reputation_period, user: small_contributor, reputation: 30
    create :user_reputation_period, user: medium_contributor, reputation: 40

    assert_search [massive_contributor, medium_contributor], User::ReputationPeriod::Search.(user_handle: "m")
  end

  private
  def assert_search(expected, actual)
    assert_equal expected.map(&:handle), actual.map(&:handle)
  end
end
