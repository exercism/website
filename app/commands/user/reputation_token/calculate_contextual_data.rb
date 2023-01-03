class User::ReputationToken::CalculateContextualData
  include Mandate
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  # This does n queries (where n is number of users).
  # This is theoretically terrible but actually works out to be much more performant for two reasons:
  # 1. MySQL's index performance ranges from 0.05s to 33s (!!) depending on how dispersed the indexes pages
  # are. First website page load therefore takes 33s and subsequent ones are pretty instant.
  # By reducing it down to n queries, we have a steady performance that's at the very low
  # end of the range (~0.5s sum for all the queries)
  # 2. We cache the values per user and invalidate the cache when a new reputation token is
  # added, so although this is n queries in the worst case - we're never really actually there.
  def initialize(user_ids, period: nil, earned_since: nil, track_id: nil, category: nil)
    @single_user = user_ids.is_a?(Integer)
    @user_ids = Array(user_ids)
    @track_id = track_id
    @category = category

    if earned_since
      @earned_since = earned_since
    elsif period
      case period.to_sym
      when :week
        @earned_since = Time.zone.today - 6.days
      when :month
        @earned_since = Time.zone.today - 29.days
      when :year
        @earned_since = Time.zone.today - 364.days
      end
    end
  end

  def call
    single_user ? data.values.first : data
  end

  memoize
  def data
    tuples.each.with_object({}) do |(user_id, user_tuples), data|
      user_tuples = user_tuples.index_by { |t| t['type'] }.transform_keys { |k| k.split("::").last }

      code_contributions = user_tuples.dig("CodeContributionToken", 'num')
      code_reviews = user_tuples.dig("CodeReviewToken", 'num')
      code_merges = user_tuples.dig("CodeMergeToken", 'num')
      exercises_authored = user_tuples.dig("ExerciseAuthorToken", 'num')
      exercises_contributed = user_tuples.dig("ExerciseContributionToken", 'num')
      solutions_mentored = user_tuples.dig("MentoredToken", 'num')
      solutions_published = user_tuples.dig("PublishedSolutionToken", 'num')

      parts = []
      parts << format(code_contributions, "PR", "created") if code_contributions
      parts << format(code_reviews, "PR", "reviewed") if code_reviews
      parts << format(code_merges, "PR", "merged") if code_merges
      parts << format(exercises_authored, "exercise", "authored") if exercises_authored
      parts << format(exercises_contributed, "exercise contribution") if exercises_contributed
      parts << format(solutions_mentored, "solution", "mentored") if solutions_mentored
      parts << format(solutions_published, "solution", "published") if solutions_published

      data[user_id] = Data.new(
        parts.join(" • "),
        user_tuples.sum { |_k, v| v['total'] }
      )
    end
  end

  def format(value, thing, suffix = nil)
    suffix = suffix ? " #{suffix}" : ""
    "#{number_with_delimiter(value)} #{thing.pluralize(value)}#{suffix}"
  end

  memoize
  def tuples
    base = User::ReputationToken
    base = base.where(category:) if category
    base = base.where('earned_on >= ?', earned_since) if earned_since
    base = base.where(track_id:) if track_id
    base = base.group(:type)
    base = base.select('type, COUNT(value) AS num, SUM(value) AS total')

    user_ids.index_with do |user_id|
      with_cache(user_id) do
        query = base.where(user_id:)
        ActiveRecord::Base.connection.select_all(query)
      end
    end
  end

  private
  attr_reader :user_ids, :single_user, :earned_since, :track_id, :category

  Data = Struct.new(:activity, :reputation)
  private_constant :Data

  def with_cache(user)
    redis = Exercism.redis_tooling_client
    user_key = User::ReputationToken.cache_hash_for(user)
    value_key = ["contextual", earned_since, track_id, category].join("|")

    # Check for a cached version
    cached = redis.hget(user_key, value_key)
    return JSON.parse(cached) if cached

    # Or yield and cache a new one
    yield.tap do |val|
      redis.hset(user_key, value_key, val.to_json)
    end
  end
end
