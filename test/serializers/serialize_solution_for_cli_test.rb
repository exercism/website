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
        file_download_base_url: "https://exercism.org/api/v1/solutions/#{solution.uuid}/files/",
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
    create(:submission, solution:, created_at:)

    output = SerializeSolutionForCLI.(solution, solution.user)
    assert_equal created_at.to_i, output[:solution][:submission][:submitted_at].to_i
  end

  test "solution_url for own solution" do
    solution = create :practice_solution
    output = SerializeSolutionForCLI.(solution, solution.user)

    assert_equal "https://test.exercism.org/tracks/ruby/exercises/bob", output[:solution][:url]
  end

  test "solution_url for published solution mentored by requester" do
    student = create :user, handle: 'anne'
    create :user_track, user: student
    solution = create :practice_solution, user: student, published_at: Time.current
    iteration = create(:iteration, solution:)
    mentor = create :user
    request = Mentor::Request::Create.(solution, "Please help")
    discussion = Mentor::Discussion::Create.(mentor, request, iteration.idx, "I'd love to help")

    output = SerializeSolutionForCLI.(solution, mentor)

    assert_equal "https://test.exercism.org/mentoring/discussions/#{discussion.uuid}", output[:solution][:url]
  end

  test "solution_url for published solution not mentored by requester" do
    student = create :user, handle: 'anne'
    solution = create :practice_solution, user: student, published_at: Time.current

    requester = create :user
    output = SerializeSolutionForCLI.(solution, requester)

    assert_equal "https://test.exercism.org/tracks/ruby/exercises/bob/solutions/anne", output[:solution][:url]
  end

  test "solution_url for unpublished solution mentored by requester" do
    user_track = create :user_track
    solution = create :practice_solution, user: user_track.user, track: user_track.track
    iteration = create(:iteration, solution:)
    mentor = create :user
    request = Mentor::Request::Create.(solution, "Please help")
    discussion = Mentor::Discussion::Create.(mentor, request, iteration.idx, "I'd love to help")

    output = SerializeSolutionForCLI.(solution, mentor)

    assert_equal "https://test.exercism.org/mentoring/discussions/#{discussion.uuid}", output[:solution][:url]
  end

  test "solution_url for unpublished solution not mentored by requester" do
    user_track = create :user_track
    solution = create :practice_solution, user: user_track.user, track: user_track.track
    requester = create :user

    output = SerializeSolutionForCLI.(solution, requester)

    assert_nil output[:solution][:url]
  end

  test "solution_url for published solution mentored by other mentor" do
    student = create :user, handle: 'anne'
    user_track = create :user_track, user: student
    solution = create :practice_solution, user: user_track.user, track: user_track.track, published_at: Time.current
    iteration = create(:iteration, solution:)
    non_mentor = create :user
    mentor = create :user
    request = Mentor::Request::Create.(solution, "Please help")
    Mentor::Discussion::Create.(mentor, request, iteration.idx, "I'd love to help")

    output = SerializeSolutionForCLI.(solution, non_mentor)

    assert_equal "https://test.exercism.org/tracks/ruby/exercises/bob/solutions/anne", output[:solution][:url]
  end

  test "solution_url for unpublished solution mentored by other mentor" do
    user_track = create :user_track
    solution = create :practice_solution, user: user_track.user, track: user_track.track
    iteration = create(:iteration, solution:)
    non_mentor = create :user
    mentor = create :user
    request = Mentor::Request::Create.(solution, "Please help")
    Mentor::Discussion::Create.(mentor, request, iteration.idx, "I'd love to help")

    output = SerializeSolutionForCLI.(solution, non_mentor)

    assert_nil output[:solution][:url]
  end

  test "solution_url for unpublished solution with pending mentor request and requester is mentor" do
    student = create :user, handle: 'anne'
    user_track = create :user_track, user: student
    solution = create :practice_solution, user: user_track.user, track: user_track.track
    create(:iteration, solution:)
    mentor = create :user, became_mentor_at: Time.current
    request = Mentor::Request::Create.(solution, "Please help")

    output = SerializeSolutionForCLI.(solution, mentor)

    assert_equal "https://test.exercism.org/mentoring/requests/#{request.uuid}", output[:solution][:url]
  end

  test "solution_url for unpublished solution with pending mentor request and requester is not mentor" do
    user_track = create :user_track
    solution = create :practice_solution, user: user_track.user, track: user_track.track
    create(:iteration, solution:)
    non_mentor = create :user, :not_mentor
    Mentor::Request::Create.(solution, "Please help")

    output = SerializeSolutionForCLI.(solution, non_mentor)

    assert_nil output[:solution][:url]
  end
end
