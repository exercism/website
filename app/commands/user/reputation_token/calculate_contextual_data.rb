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
    prefetch_cached_values!

    assembled_data.tap { flush_cached_values! }
  end

  def assembled_data
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

  CACHE_KEYS = %i[total details].freeze
  private_constant :CACHE_KEYS

  # Read every value in one pipelined call rather than an hget per user per
  # key. The contributors list asks for 20 users, which would otherwise be 40
  # sequential round-trips. Writes for the misses are batched the same way.
  def prefetch_cached_values!
    @cached_values = {}
    return if user_ids.empty?

    fields = user_ids.flat_map { |user_id| CACHE_KEYS.map { |key| [user_id, key] } }
    values = redis.pipelined do |pipeline|
      fields.each { |user_id, key| pipeline.hget(cache_hash_key(user_id), cache_value_key(key)) }
    end

    @cached_values = fields.zip(values).to_h
  end

  def flush_cached_values!
    return if pending_writes.empty?

    redis.pipelined do |pipeline|
      pending_writes.each do |user_id, key, value|
        pipeline.hset(cache_hash_key(user_id), cache_value_key(key), value.to_json)
      end
    end

    pending_writes.clear
  end

  def pending_writes = @pending_writes ||= []

  def cache_hash_key(user_id) = User::ReputationToken.cache_hash_for(user_id)
  def cache_value_key(key) = ["contextual/#{key}", period, track_id, category].join("|")

  memoize
  def redis = Exercism.redis_cache_client

  def with_cache(user_id, key)
    # Check for a cached version
    cached = @cached_values[[user_id, key]]
    if cached
      parsed_value = JSON.parse(cached)

      # Sometimes, due to someone checking the contributors page while
      # the reputation periods are being updated in their nightly cycle,
      # this data is wrong (either empty array or 0).
      # We shouldn't honour this and should act as if this isn't cached.
      return parsed_value if parsed_value.present? && parsed_value != 0
    end

    # Or yield and queue it up to be cached
    yield.tap { |val| pending_writes << [user_id, key, val] }
  end
end
