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
  initialize_with :user_ids, period: nil, track_id: nil, category: nil do
    @single_user = user_ids.is_a?(Integer)
    @period = period || :forever
    @user_ids = Array(user_ids)
  end

  def call
    single_user? ? data.values.first : data
  end

  private
  memoize
  def data
    user_ids.each_with_object({}) do |user_id, res|
      occs = reputation_occurrences(user_id)
      code_contributions = occs['building']
      maintenance = occs['maintaining']
      exercises_contributed = occs['authoring']
      solutions_mentored = occs['mentoring']
      solutions_published = occs['publishing']

      parts = []
      parts << format(code_contributions, "PR", "created") if code_contributions
      parts << format(maintenance, "PR", "reviewed and/or merged") if maintenance
      parts << format(exercises_contributed, "exercise contribution") if exercises_contributed
      parts << format(solutions_mentored, "solution", "mentored") if solutions_mentored
      parts << format(solutions_published, "solution", "published") if solutions_published.to_i.positive?

      res[user_id] = Data.new(
        parts.join(" • "),
        total_reputation(user_id)
      )
    end
  end

  def format(value, thing, suffix = nil)
    suffix = suffix ? " #{suffix}" : ""
    "#{number_with_delimiter(value)} #{thing.pluralize(value)}#{suffix}"
  end

  def total_reputation(user_id)
    with_cache(user_id, :total) do
      User::ReputationPeriod.
        where(user_id:).
        where(track_id: track_id.to_i).
        where(period:).
        where(category: category || :any).
        sum(:reputation)
    end
  end

  def reputation_occurrences(user_id)
    with_cache(user_id, :details) do
      data = User::ReputationPeriod.
        where(user_id:).
        where(track_id: track_id.to_i).
        where(period:)
      data = data.where(category:) if category
      data = data.group(:category).sum(:num_tokens)

      unless category
        publishing_tokens = User::ReputationToken.where(user_id:, category: :publishing)
        publishing_tokens = publishing_tokens.where(track_id:) if track_id
        publishing_tokens = publishing_tokens.where('earned_on >= ?', earned_since) if earned_since
        data["publishing"] = publishing_tokens.count
      end

      data
    end
  end

  memoize
  def earned_since
    case period.to_sym
    when :week
      Time.zone.today - 6.days
    when :month
      Time.zone.today - 29.days
    when :year
      Time.zone.today - 364.days
    end
  end

  def single_user? = @single_user

  Data = Struct.new(:activity, :reputation)
  private_constant :Data

  def with_cache(user_id, key)
    redis = Exercism.redis_tooling_client
    user_key = User::ReputationToken.cache_hash_for(user_id)
    value_key = ["contextual/#{key}", period, track_id, category].join("|")

    # Check for a cached version
    cached = redis.hget(user_key, value_key)
    if cached
      parsed_value = JSON.parse(cached)

      # Sometimes, due to someone checking the contributors page while
      # the reputation periods are being updated in their nightly cycle,
      # this data is wrong (either empty array or 0).
      # We shouldn't honour this and should act as if this isn't cached.
      return parsed_value if parsed_value.present? && parsed_value != 0
    end

    # Or yield and cache a new one
    yield.tap do |val|
      redis.hset(user_key, value_key, val.to_json)
    end
  end
end
