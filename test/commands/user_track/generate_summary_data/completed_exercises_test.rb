require "test_helper"

class UserTrack::GenerateSummaryData::CompletedExercisesTest < ActiveSupport::TestCase
  test "exercise_completion_dates" do
    freeze_time do
      track = create :track
      user = create :user
      user_track = create(:user_track, track:, user:)
      pe_1 = create :practice_exercise, track:, slug: 'bob'
      pe_2 = create :practice_exercise, track:, slug: 'food'
      pe_3 = create :practice_exercise, track:, slug: 'lasagna'
      create :practice_solution, user:, completed_at: Time.current - 1.week, exercise: pe_1
      create :practice_solution, user:, completed_at: Time.current - 2.weeks, exercise: pe_2
      create :practice_solution, user:, exercise: pe_3

      summary = summary_for(user_track)
      assert_equal [
        (Time.current - 1.week).to_i,
        (Time.current - 2.weeks).to_i
      ].sort, summary.exercise_completion_dates.sort
    end
  end

  private
  def summary_for(user_track)
    user_track = UserTrack.find(user_track.id)
    UserTrack::Summary.new(
      UserTrack::GenerateSummaryData.(user_track.track, user_track)
    )
  end
end
