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
    filter_data(requested_category, requested_track_id, reputation_points)
  end

  def num_reputation_occurrences(requested_category, requested_track_id)
    filter_data(requested_category, requested_track_id, reputation_occurrences)
  end

  def filter_data(requested_category, requested_track_id, data)
    requested_category = requested_category.to_s
    res = data.find do |(track_id, category), _|
      next unless track_id == requested_track_id
      next unless category == requested_category

      true
    end
    res ? res[1] : 0
  end

  memoize
  def tracks
    ::Track.where(id: reputation_occurrences.keys.map(&:first).compact).order(:title)
  end

  memoize
  def reputation_points
    data = user.reputation_periods.
      where(period: :forever).
      group(:track_id, :category).sum(:reputation)

    grouped_sums = user.reputation_tokens.where(category: :publishing).group(:track_id).sum(:value)
    grouped_sums.each do |track_id, value|
      data[[track_id, "publishing"]] = value
    end
    data[[0, "publishing"]] = grouped_sums.sum(&:second)
    data[[0, "misc"]] = user.reputation_tokens.where(category: :misc, track_id: nil).sum(:value)
    data
  end

  memoize
  def reputation_occurrences
    data = user.reputation_periods.
      where(period: :forever).
      group(:track_id, :category).sum(:num_tokens)

    grouped_counts = user.reputation_tokens.where(category: :publishing).group(:track_id).count
    grouped_counts.each do |track_id, value|
      data[[track_id, "publishing"]] = value
    end
    data[[0, "publishing"]] = grouped_counts.sum(&:second)
    data[[0, "misc"]] = user.reputation_tokens.where(category: :misc, track_id: nil).count
    data
  end
end
