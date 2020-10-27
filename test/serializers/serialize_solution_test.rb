require 'test_helper'

class SerializeSolutionTest < ActiveSupport::TestCase
  test "basic to_hash" do
    files = [".meta/config.json", "README.md", "bob.rb", "bob_test.rb", "subdir/more_bob.rb"]
    Git::Exercise.any_instance.stubs(code_filepaths: files)

    solution = create :concept_solution
    create :user_track, user: solution.user, track: solution.track
    expected = {
      solution: {
        id: solution.uuid,
        url: "https://test.exercism.io/tracks/ruby/exercises/bob",
        user: {
          handle: solution.user.handle,
          is_requester: true
        },
        exercise: {
          id: solution.exercise.slug,
          instructions_url: "https://test.exercism.io/tracks/ruby/exercises/bob",
          track: {
            id: solution.track.slug,
            language: solution.track.title
          }
        },
        file_download_base_url: "https://api.exercism.io/v1/solutions/#{solution.uuid}/files/",
        files: Set.new([".meta/config.json", "README.md", "bob.rb", "bob_test.rb", "subdir/more_bob.rb"]),
        submission: nil
      }
    }

    assert_equal expected, SerializeSolution.(solution, solution.user)
  end

  # TODO: I think we don't need this test any more as it was
  # only checking the exercise files, which are now checked elsewhere.
  # But I'm leaving it here for now in case I was wrong.

  # test "ignore submission files that match ignore_regexp" do
  #   solution = create :concept_solution
  #   create :user_track, user: solution.user, track: solution.track

  #   # Create an ignore file, check it matches the pattern
  #   # for sanity, then stub the git exercise
  #   filepath = 'ignore.rb'
  #   assert filepath =~ solution.track.repo.ignore_regexp
  #   Git::Exercise.any_instance.stubs(code_filepaths: [filepath])

  #   output = SerializeSolution.(solution, solution.user)
  #   refute_includes output[:solution][:files], filepath
  # end

  # test "includes all solution files" do
  #   solution = create :concept_solution
  #   track = solution.track
  #   create :user_track, user: solution.user, track: track

  #   submission = create :submission, solution: solution
  #   valid_filepath = "foobar.js"
  #   ignore_filepath = "ignore.rb"
  #   create :submission_file, submission: submission, filename: valid_filepath
  #   create :submission_file, submission: submission, filename: ignore_filepath

  #   # Ensure that changing our fixture doesn't break this test
  #   refute valid_filepath =~ track.repo.ignore_regexp
  #   assert ignore_filepath =~ track.repo.ignore_regexp

  #   output = SerializeSolution.(solution, solution.user)
  #   assert_includes output[:solution][:files], valid_filepath
  #   assert_includes output[:solution][:files], ignore_filepath
  # end

  test "to_hash with different requester" do
    user = create :user
    solution = create :concept_solution
    create :user_track, user: solution.user, track: solution.track

    output = SerializeSolution.(solution, user)
    refute output[:solution][:user][:is_requester]
  end

  test "handle is alias when anonymous" do
    solution = create :concept_solution
    create :user_track, anonymous_during_mentoring: true, user: solution.user, track: solution.track

    output = SerializeSolution.(solution, solution.user)
    assert_equal solution.anonymised_user_handle, output[:solution][:user][:handle]
  end

  test "submission is represented correctly" do
    solution = create :concept_solution
    create :user_track, user: solution.user, track: solution.track

    created_at = Time.current.getutc - 1.week
    create :submission, solution: solution, created_at: created_at

    output = SerializeSolution.(solution, solution.user)
    assert_equal created_at.to_i, output[:solution][:submission][:submitted_at].to_i
  end

  test "solution_url should be /mentoring/solutions if not user" do
    solution = create :concept_solution
    create :user_track, user: solution.user, track: solution.track
    mentor = create :user
    output = SerializeSolution.(solution, mentor)

    assert_nil output[:solution][:url]
  end
end
