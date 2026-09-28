class AssembleContributionsSummary
  include Mandate

  initialize_with :user, for_self: Mandate::NO_DEFAULT

  def call
    {
      tracks: [
        SerializeTrackForSelect.all_track.merge(categories: categories_data),
        *tracks.map { |track| SerializeTrackForSelect.(track).merge(categories: categories_data(track.id)) }
      ],
      handle: for_self ? nil : user.handle,
      links: {
        contributions: Exercism::Routes.contributions_profile_url(user.handle)
      }
    }
  end

  # This should take <10ms so it doesn't need caching, which is
  # good because there's a lot of data to try and work out
  # cache invalidation for here.
  def categories_data(track_id = 0)
    # The frontend owns the wording (and pluralisation) of each metric, so we
    # send only the raw count: a sentence built here would be English-only.
    %i[publishing mentoring authoring building maintaining].map do |id|
      {
        id:,
        reputation: num_reputation_points(id, track_id),
        metric_count: num_reputation_occurrences(id, track_id).to_i
      }
    end + [
      {
        id: :other,
        reputation: num_reputation_points(:misc, track_id)
      }
    ]
  end

  private
  def num_reputation_points(requested_category, requested_track_id)
    reputation_points.fetch([requested_track_id, requested_category.to_s], 0)
  end

  def num_reputation_occurrences(requested_category, requested_track_id)
    reputation_occurrences.fetch([requested_track_id, requested_category.to_s], 0)
  end

  memoize
  def tracks
    ::Track.where(id: reputation_occurrences.keys.map(&:first).compact).order(:title)
  end

  memoize
  def reputation_points
    data = period_totals.to_h { |track_id, category, reputation, _| [[track_id, category], reputation.to_i] }
    publishing_totals.each { |track_id, value, _| data[[track_id, "publishing"]] = value.to_i }
    data[[0, "publishing"]] = publishing_totals.sum { |_, value, _| value.to_i }
    data[[0, "misc"]] = misc_totals[0].to_i
    data
  end

  memoize
  def reputation_occurrences
    data = period_totals.to_h { |track_id, category, _, num_tokens| [[track_id, category], num_tokens.to_i] }
    publishing_totals.each { |track_id, _, count| data[[track_id, "publishing"]] = count }
    data[[0, "publishing"]] = publishing_totals.sum { |_, _, count| count }
    data[[0, "misc"]] = misc_totals[1]
    data
  end

  memoize
  def period_totals
    user.reputation_periods.
      where(period: :forever).
      group(:track_id, :category).
      pluck(:track_id, :category, Arel.sql("SUM(reputation)"), Arel.sql("SUM(num_tokens)"))
  end

  memoize
  def publishing_totals
    user.reputation_tokens.
      where(category: :publishing).
      group(:track_id).
      pluck(:track_id, Arel.sql("SUM(value)"), Arel.sql("COUNT(*)"))
  end

  memoize
  def misc_totals
    user.reputation_tokens.
      where(category: :misc, track_id: nil).
      pick(Arel.sql("SUM(value)"), Arel.sql("COUNT(*)"))
  end
end
