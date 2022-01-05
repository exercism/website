class AssembleJourneyOverview
  include Mandate

  initialize_with :user

  def call
    {
      overview: {
        learning: {
          tracks: learning_tracks_data,
          links: {
            solutions: Exercism::Routes.solutions_journey_url,
            # TODO: (optional)
            fable: "#"
          }
        },
        mentoring: mentoring_data,
        contributing: AssembleContributionsSummary.(user, for_self: true),
        badges: {
          badges: SerializeUserAcquiredBadges.(user.acquired_badges.revealed),
          links: {
            badges: Exercism::Routes.badges_journey_url
          }
        }
      }
    }
  end

  private
  def learning_tracks_data
    user.user_tracks.includes(:track).map do |user_track|
      track = user_track.track

      first_completion = user_track.exercise_completion_dates.min
      if first_completion && first_completion < (Time.current - 10.months).to_i
        progress_period = "Last 12 months"
        progress_data = track_chart_values(user_track, 12.months.ago, :month, 12, 12)
      elsif first_completion && first_completion < (Time.current - 6.weeks).to_i
        progress_period = "Last 10 weeks"
        progress_data = track_chart_values(user_track, 10.weeks.ago, :cweek, 10.weeks.ago.to_datetime.end_of_year.cweek, 10)
      else
        progress_period = "Last 14 days"
        progress_data = track_chart_values(user_track, 14.days.ago, :yday, 14.days.ago.to_datetime.end_of_year.yday, 14)
      end

      {
        title: track.title,
        slug: track.slug,
        icon_url: track.icon_url,
        num_exercises: user_track.num_exercises,
        num_completed_exercises: user_track.num_completed_exercises,
        num_concepts_learnt: user_track.num_concepts_learnt,
        num_lines: 250, # TODO: (Required)
        num_solutions: user_track.num_started_exercises,
        started_at: user_track.created_at,
        num_completed_mentoring_discussions: num_completed_mentoring_discussions(track.id),
        num_in_progress_mentoring_discussions: num_in_progress_mentoring_discussions(track.id),
        num_queued_mentoring_requests: mentoring_request_counts[track.id].to_i,
        progress_chart: {
          period: progress_period,
          data: progress_data
        }
      }
    end
  end

  memoize
  def mentoring_discussion_counts
    Mentor::Discussion.joins(:request).where('mentor_requests.student_id': user.id).group(:track_id, :status).count
  end

  memoize
  def mentoring_request_counts
    Mentor::Request.pending.where(student_id: user.id).group(:track_id).count
  end

  def num_completed_mentoring_discussions(track_id)
    track_data = mentoring_discussion_counts.select { |group, _| group[0] == track_id }
    return 0 if track_data.blank?

    track_data.sum { |group, val| group[1] == 'finished' ? val : 0 }
  end

  def num_in_progress_mentoring_discussions(track_id)
    track_data = mentoring_discussion_counts.select { |group, _| group[0] == track_id }
    return 0 if track_data.blank?

    track_data.values.sum - num_completed_mentoring_discussions(track_id)
  end

  def track_chart_values(user_track, since, group_by, max, range)
    # Get all the completion dates since `since` and count how many are in each
    # `group_by` group. (e.g. since 10.weeks.ago grouped by cweek).
    since = since.to_i
    data = user_track.exercise_completion_dates.select { |d| d > since }.
      map { |d| Time.zone.at(d).to_date.send(group_by) }.
      group_by(&:itself).
      transform_values(&:count)

    # Build a range that wraps around the end of the year, with values or zeros.
    current = Date.current.send(group_by)
    ((current - range)...current).to_a.map { |w| (w % max) + 1 }.map { |w| data.fetch(w, 0) }
  end

  def mentoring_data
    grouped_discussions = user.mentor_discussions.joins(solution: :exercise).group('exercises.track_id').count
    grouped_students = user.mentor_discussions.joins(solution: :exercise).
      group('exercises.track_id').select('solutions.user_id').distinct.count

    tracks = Track.where(id: grouped_discussions.keys).order('title asc')
    tracks_data = tracks.map do |track|
      {
        title: track.title,
        slug: track.slug,
        icon_url: track.icon_url,
        num_discussions: grouped_discussions[track.id],
        num_students: grouped_students[track.id]
      }
    end

    num_total_discussions = grouped_discussions.values.sum
    num_total_students = user.mentor_discussions.joins(:solution).select('solutions.user_id').distinct.count

    {
      tracks: tracks_data,
      totals: {
        discussions: num_total_discussions,
        students: num_total_students,
        ratio: num_total_students.zero? ? 0 : num_total_discussions.to_f / num_total_students
      },
      ranks: {
        discussions: nil,
        students: nil
      }
    }
  end
end
