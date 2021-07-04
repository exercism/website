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
            fable: "#" # TODO
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
      {
        title: track.title,
        slug: track.slug,
        icon_url: track.icon_url,
        num_exercises: user_track.num_exercises,
        num_completed_exercises: user_track.num_completed_exercises,
        num_concepts_learnt: user_track.num_concepts_learnt,
        num_lines: 250, # TODO
        num_solutions: user_track.num_started_exercises
      }
    end
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
        ratio: num_total_discussions.to_f / num_total_students
      },
      ranks: {
        discussions: 1, # TODO
        students: 3, # TODO
        ratio: 10
      }
    }
  end
end
