require 'test_helper'

class SerializeSolutionForCLITest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :concept_solution
    create :user_track, user: solution.user, track: solution.track
    expected = {
      solution: {
        id: solution.uuid,
        url: "https://test.exercism.org/tracks/ruby/exercises/strings",
        user: {
          handle: solution.user.handle,
          is_requester: true
        },
        exercise: {
          id: solution.exercise.slug,
          instructions_url: "https://test.exercism.org/tracks/ruby/exercises/strings",
          track: {
            id: solution.track.slug,
            language: solution.track.title
          }
        },
        # TODO: Change to exercism.org
        file_download_base_url: "https://exercism.lol/api/v1/solutions/#{solution.uuid}/files/",
        files: Set.new([
                         ".exercism/config.json", "README.md", "HELP.md", "HINTS.md",
                         "log_line_parser.rb", "log_line_parser_test.rb"
                       ]),
        submission: nil
      }
    }

    assert_equal expected, SerializeSolutionForCLI.(solution, solution.user)
  end

  test "to_hash with different requester" do
    user = create :user
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track

    output = SerializeSolutionForCLI.(solution, user)
    refute output[:solution][:user][:is_requester]
  end

  test "handle is alias when anonymous" do
    solution = create :practice_solution
    create :user_track, anonymous_during_mentoring: true, user: solution.user, track: solution.track

    output = SerializeSolutionForCLI.(solution, solution.user)
    assert_equal solution.anonymised_user_handle, output[:solution][:user][:handle]
  end

  test "submission is represented correctly" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track

    created_at = Time.current.getutc - 1.week
    create :submission, solution: solution, created_at: created_at

    output = SerializeSolutionForCLI.(solution, solution.user)
    assert_equal created_at.to_i, output[:solution][:submission][:submitted_at].to_i
  end

  test "solution_url should be /mentoring/solutions if not user" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    mentor = create :user
    output = SerializeSolutionForCLI.(solution, mentor)

    assert_nil output[:solution][:url]
  end
end
