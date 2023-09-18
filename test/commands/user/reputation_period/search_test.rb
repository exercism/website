require "test_helper"

class User::ReputationPeriod::SearchTest < ActiveSupport::TestCase
  test "no options returns all users that have contributed, ordered by rep, then id" do
    create :user # Never contributed
    big_contributor = create :user, handle: 'big'
    small_3_contributor = create :user, handle: 'small-3'
    small_1_contributor = create :user, handle: 'small-1'
    small_2_contributor = create :user, handle: 'small-2'
    medium_contributor = create :user, handle: 'medium'

    # Add other contribution rows to ensure they are not counted
    create :user_reputation_period, user: small_1_contributor, period: :year, reputation: 1000
    create :user_reputation_period, user: small_1_contributor, about: :track, reputation: 1000
    create :user_reputation_period, user: small_1_contributor, category: :building, reputation: 1000

    create :user_reputation_period, user: big_contributor, period: :forever, reputation: 50
    create :user_reputation_period, user: small_1_contributor, period: :forever, reputation: 30
    create :user_reputation_period, user: small_2_contributor, period: :forever, reputation: 30
    create :user_reputation_period, user: small_3_contributor, period: :forever, reputation: 30
    create :user_reputation_period, user: medium_contributor, period: :forever, reputation: 40

    assert_search [big_contributor, medium_contributor, small_1_contributor, small_2_contributor, small_3_contributor],
      User::ReputationPeriod::Search.()
  end

  test "handles empty inputs" do
    user = create :user
    create :user_reputation_period, user:, reputation: 1000

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
    mass_contributor = create :user, handle: 'mass'
    massi_contributor = create :user, handle: 'massi'
    amassi_contributor = create :user, handle: 'amassi'

    create :user_reputation_period, user: mass_contributor, reputation: 50
    create :user_reputation_period, user: massi_contributor, reputation: 30
    create :user_reputation_period, user: amassi_contributor, reputation: 40

    assert_empty User::ReputationPeriod::Search.(user_handle: "m")
    assert_search [mass_contributor], User::ReputationPeriod::Search.(user_handle: "mass")
    assert_search [massi_contributor], User::ReputationPeriod::Search.(user_handle: "massi")
    assert_search [amassi_contributor], User::ReputationPeriod::Search.(user_handle: "amassi")
  end

  test "handles missing periods correctly" do
    week_contributor = create :user, handle: 'week'
    year_contributor = create :user, handle: 'year'
    forever_contributor = create :user, handle: 'forever'

    # This data is contrived to test that only "forever" periods are returned if
    # the value is missing or incorrect
    create :user_reputation_period, user: week_contributor, period: :week
    create :user_reputation_period, user: year_contributor, period: :year
    create :user_reputation_period, user: forever_contributor, period: :forever

    assert_search [week_contributor], User::ReputationPeriod::Search.(period: :week) # Sanity
    assert_search [week_contributor], User::ReputationPeriod::Search.(period: 'week') # Sanity
    assert_search [forever_contributor], User::ReputationPeriod::Search.(period: '')
    assert_search [forever_contributor], User::ReputationPeriod::Search.(period: nil)
    assert_search [forever_contributor], User::ReputationPeriod::Search.(period: 'foobar')
  end

  test "handles missing categories correctly" do
    mentoring_contributor = create :user, handle: 'mentoring'
    building_contributor = create :user, handle: 'building'
    any_contributor = create :user, handle: 'any'

    # This data is contrived to test that only "forever" periods are returned if
    # the value is missing or incorrect
    create :user_reputation_period, user: mentoring_contributor, category: :mentoring
    create :user_reputation_period, user: building_contributor, category: :building
    create :user_reputation_period, user: any_contributor, category: :any

    assert_search [mentoring_contributor], User::ReputationPeriod::Search.(category: :mentoring) # Sanity
    assert_search [mentoring_contributor], User::ReputationPeriod::Search.(category: 'mentoring') # Sanity
    assert_search [any_contributor], User::ReputationPeriod::Search.(category: '')
    assert_search [any_contributor], User::ReputationPeriod::Search.(category: nil)
    assert_search [any_contributor], User::ReputationPeriod::Search.(category: 'foobar')
  end

  test "does not consider rows categories with zero reputation" do
    zero_contributor = create :user, handle: 'zero'
    ten_contributor = create :user, handle: 'ten'

    create :user_reputation_period, user: zero_contributor, reputation: 0
    create :user_reputation_period, user: ten_contributor, reputation: 10

    assert_search [ten_contributor], User::ReputationPeriod::Search.()
  end

  private
  def assert_search(expected, actual)
    assert_equal expected.map(&:handle), actual.map(&:handle)
  end
end
