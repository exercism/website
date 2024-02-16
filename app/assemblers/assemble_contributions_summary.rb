class AssembleContributionsSummary
  include Mandate
  include ActionView::Helpers::NumberHelper

  initialize_with :user, for_self: Mandate::NO_DEFAULT

  def call
    {
      tracks: [
        SerializeTrackForSelect::ALL_TRACK.merge(categories: categories_data),
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
    metrics = {
      publishing: publishing_metrics(track_id),
      mentoring: mentoring_metrics(track_id),
      authoring: authoring_metrics(track_id),
      building: building_metrics(track_id),
      maintaining: maintaining_metrics(track_id)
    }

    [
      {
        id: :publishing,
        reputation: num_reputation_points(:publishing, track_id),
        metric_full: metrics[:publishing][0],
        metric_short: metrics[:publishing][1]
      },
      {
        id: :mentoring,
        reputation: num_reputation_points(:mentoring, track_id),
        metric_full: metrics[:mentoring][0],
        metric_short: metrics[:mentoring][1]
      },
      {
        id: :authoring,
        reputation: num_reputation_points(:authoring, track_id),
        metric_full: metrics[:authoring][0],
        metric_short: metrics[:authoring][1]
      },
      {
        id: :building,
        reputation: num_reputation_points(:building, track_id),
        metric_full: metrics[:building][0],
        metric_short: metrics[:building][1]
      },
      {
        id: :maintaining,
        reputation: num_reputation_points(:maintaining, track_id),
        metric_full: metrics[:maintaining][0],
        metric_short: metrics[:maintaining][1]
      },
      {
        id: :other,
        reputation: num_reputation_points(:misc, track_id)
      }
    ]
  end

  private
  def publishing_metrics(track_id = 0)
    c = num_reputation_occurrences(:publishing, track_id).to_i

    return ["No solutions published", "No solutions"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'solution'.pluralize(c)}"
    ["#{short} published", short]
  end

  def authoring_metrics(track_id = 0)
    c = num_reputation_occurrences(:authoring, track_id).to_i

    return ["No exercises contributed", "No exercises"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'exercise'.pluralize(c)}"
    ["#{short} contributed", short]
  end

  def mentoring_metrics(track_id = 0)
    c = num_reputation_occurrences(:mentoring, track_id).to_i

    return ["No students mentored", "No students"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'student'.pluralize(c)}"
    ["#{short} mentored", short]
  end

  def building_metrics(track_id = 0)
    c = num_reputation_occurrences(:building, track_id).to_i

    return ["No PRs accepted", "No PRs accepted"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'PR'.pluralize(c)} accepted"
    [short, short]
  end

  def maintaining_metrics(track_id = 0)
    c = num_reputation_occurrences(:maintaining, track_id).to_i

    return ["No PRs reviewed", "No PRs reviewed"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'PR'.pluralize(c)} reviewed"
    [short, short]
  end

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
