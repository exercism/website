class AssembleContributionsSummary
  include Mandate
  include ActionView::Helpers::NumberHelper

  # TODO: figure out why mandate doesn't work for this class
  def self.call(...)
    new(...).()
  end

  def initialize(user, for_self:)
    @user = user
    @for_self = for_self
  end

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
  def categories_data(track_id = nil)
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
  attr_reader :user, :for_self

  def publishing_metrics(track_id = nil)
    c = track_id ? published_solutions[track_id] : published_solutions.values.sum

    return ["No solutions published", "No solutions"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'solution'.pluralize(c)}"
    ["#{short} published", short]
  end

  def authoring_metrics(track_id = nil)
    c = track_id ? authorships[track_id] : authorships.values.sum

    return ["No exercises contributed", "No exercises"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'exercise'.pluralize(c)}"
    ["#{short} contributed", short]
  end

  def mentoring_metrics(track_id = nil)
    c = track_id ? mentored_students[track_id] : mentored_students.values.sum

    return ["No students mentored", "No students"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'student'.pluralize(c)}"
    ["#{short} mentored", short]
  end

  def building_metrics(track_id = nil)
    c = num_reputation_occurrences(:building, track_id).to_i

    return ["No PRs accepted", "No PRs accepted"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'PR'.pluralize(c)} accepted"
    [short, short]
  end

  def maintaining_metrics(track_id = nil)
    c = num_reputation_occurrences(:maintaining, track_id).to_i

    return ["No PRs reviewed", "No PRs reviewed"] if c.to_i.zero?

    short = "#{number_with_delimiter(c)} #{'PR'.pluralize(c)} reviewed"
    [short, short]
  end

  def num_reputation_points(requested_category, requested_track_id = nil)
    requested_category = requested_category.to_s
    reputation_points.select do |(track_id, category), _|
      category == requested_category && (requested_track_id ? track_id == requested_track_id : true)
    end.values.sum
  end

  def num_reputation_occurrences(requested_category, requested_track_id)
    requested_category = requested_category.to_s
    reputation_occurrences.select do |(track_id, category), _|
      category == requested_category && (requested_track_id ? track_id == requested_track_id : true)
    end.values.sum
  end

  memoize
  def tracks
    ::Track.where(id: reputation_occurrences.keys.map(&:first).compact)
  end

  memoize
  def published_solutions
    user.solutions.published.joins(:exercise).group("exercises.track_id").count
  end

  memoize
  def authorships
    q_1 = Exercise.where(id: user.authorships.select(:exercise_id))
    q_2 = Exercise.where(id: user.contributorships.select(:exercise_id))
    q_1.or(q_2).distinct(:id).group(:track_id).count
  end

  memoize
  def mentored_students
    user.mentor_discussions.joins(solution: :exercise).group('exercises.track_id').
      select('solutions.user_id').distinct.count
  end

  memoize
  def reputation_points
    @user.reputation_tokens.group(:track_id, :category).sum(:value)
  end

  memoize
  def reputation_occurrences
    @user.reputation_tokens.group(:track_id, :category).count
  end
end
