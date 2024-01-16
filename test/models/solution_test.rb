require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
  test "broadcast broadcasts self" do
    solution = create :concept_solution

    SolutionChannel.expects(:broadcast!).with(solution)

    solution.broadcast!
  end

  %i[concept_solution practice_solution].each do |solution_type|
    test "#{solution_type}: sets uuid" do
      solution = build solution_type, uuid: nil
      assert_nil solution.uuid
      solution.save!
      refute_nil solution.uuid
    end

    test "#{solution_type}: doesn't override uuid" do
      uuid = "foobar"
      solution = build(solution_type, uuid:)
      assert_equal uuid, solution.uuid
      solution.save!
      assert_equal uuid, solution.uuid
    end

    test "#{solution_type}: git_slug and git_sha are set correctly" do
      solution = create solution_type
      assert_equal solution.exercise.git_sha, solution.git_sha
      assert_equal solution.exercise.slug, solution.git_slug
    end
  end

  test "status" do
    solution = create :concept_solution
    assert_equal :started, solution.reload.status.to_sym

    create(:iteration, solution:)
    assert_equal :iterated, solution.reload.status.to_sym

    solution.update!(completed_at: Time.current)
    assert_equal :completed, solution.reload.status.to_sym

    solution.update!(published_at: Time.current)
    assert_equal :published, solution.reload.status.to_sym
  end

  test "update_iteration_status!" do
    solution = create :concept_solution

    solution.expects(:update_column).with(:iteration_status, :testing)
    create(:iteration, solution:, submission: create(:submission, tests_status: :queued))

    # Manually repeat the stubbed call
    solution.update!(iteration_status: :testing)

    solution.expects(:update_column).never
    solution.update_iteration_status!
  end

  test "update_iteration_status! does not call unncessarily" do
    solution = create :concept_solution

    solution.update_iteration_status!
    assert_nil solution.reload.iteration_status

    create(:iteration, solution:, submission: create(:submission, tests_status: :queued))
    solution.update_iteration_status!
    assert_equal :testing, solution.reload.iteration_status

    create(:iteration, solution:, submission: create(:submission, tests_status: :passed))
    solution.update_iteration_status!
    assert_equal :no_automated_feedback, solution.reload.iteration_status

    solution.expects(:update_column).never
  end

  test "published_iterations" do
    solution = create :concept_solution
    it_1 = create(:iteration, solution:)
    it_2 = create(:iteration, solution:)
    create :iteration, solution:, deleted_at: Time.current

    assert_empty solution.published_iterations

    solution.update(published_at: Time.current)
    assert_equal [it_1, it_2], solution.published_iterations

    solution.update(published_iteration: it_2)
    assert_equal [it_2], solution.published_iterations
  end

  test "ignore deleted published_iterations" do
    solution = create :concept_solution, :published
    old = create(:iteration, solution:)
    deleted = create :iteration, solution:, deleted_at: Time.current
    solution.update(published_iteration: deleted)

    assert_equal [old], solution.published_iterations
  end

  test "downloaded?" do
    refute create(:concept_solution, downloaded_at: nil).downloaded?
    assert create(:concept_solution, downloaded_at: Time.current).downloaded?
  end

  test "iterated?" do
    solution = create :concept_solution
    refute solution.iterated?

    create(:iteration, solution:)
    assert solution.reload.iterated?
  end

  test "submitted?" do
    solution = create :concept_solution
    refute solution.submitted?

    create(:submission, solution:)
    assert solution.submitted?
  end

  test "#completed?" do
    refute create(:concept_solution, completed_at: nil).completed?
    assert create(:concept_solution, completed_at: Time.current).completed?
  end

  test "#published?" do
    refute create(:concept_solution, published_at: nil).published?
    assert create(:concept_solution, published_at: Time.current).published?
  end

  test ".completed and .uncompleted scopes" do
    completed = create :concept_solution, completed_at: Time.current
    not_completed = create :concept_solution, completed_at: nil

    assert_equal [completed], Solution.completed
    assert_equal [not_completed], Solution.not_completed
  end

  test ".published scope" do
    published = create(:concept_solution, published_at: Time.current)
    create(:concept_solution, published_at: nil)

    assert [published], Solution.published
  end

  test ".for" do
    user = create :user
    exercise = create :concept_exercise
    create(:concept_solution, user:)
    create(:concept_solution, exercise:)
    solution = create(:concept_solution, user:, exercise:)

    assert_equal solution, Solution.for(user, exercise)
  end

  test "anonymised_user_handle" do
    solution_1 = create :concept_solution
    solution_2 = create :concept_solution

    assert_equal solution_1.anonymised_user_handle,
      "anonymous-#{Digest::SHA1.hexdigest("#{solution_1.id}-#{solution_1.uuid}")}"

    assert_equal solution_2.anonymised_user_handle,
      "anonymous-#{Digest::SHA1.hexdigest("#{solution_2.id}-#{solution_2.uuid}")}"
  end

  test "instructions is correct" do
    # TODO: Use an old sha to check the right content is returned.
    skip
    solution = create :practice_solution
    assert_equal instructions, solution.instructions
  end

  test "#exercise_files_for_editor returns exercise files" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    expected_filenames = ["log_line_parser.rb"]
    assert_equal expected_filenames, solution.exercise_files_for_editor.keys
    file = solution.exercise_files_for_editor["log_line_parser.rb"]
    assert file[:content].start_with?("module LogLineParser")
    assert_equal :exercise, file[:type]
  end

  test "#files_for_editor returns solution files" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    expected_filenames = ["log_line_parser.rb"]
    assert_equal expected_filenames, solution.files_for_editor.keys
    file = solution.files_for_editor["log_line_parser.rb"]
    assert file[:content].start_with?("module LogLineParser")
    assert_equal :exercise, file[:type]

    # Add a submission to override them
    submission = create(:submission, solution:)
    create :submission_file, submission:, filename: "log_line_parser.rb", content: "foobar1"
    create :submission_file, submission:, filename: "something_else.rb", content: "foobar2"

    expected_filenames = ["log_line_parser.rb", "something_else.rb"]
    assert_equal expected_filenames, solution.files_for_editor.keys

    file_1 = solution.files_for_editor["log_line_parser.rb"]
    assert "foobar1", file_1[:content]
    assert_equal :solution, file_1[:type]

    file_2 = solution.files_for_editor["something_else.rb"]
    assert "foobar2", file_2[:content]
    assert_equal :legacy, file_2[:type]
  end

  test "read_file for concept exercise returns exercise file" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = solution.read_file('log_line_parser.rb')
    assert contents.start_with?('module LogLineParser')
  end

  test "read_file for practice exercise returns exercise file" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = solution.read_file('bob.rb')
    assert contents.start_with?('stub content')
  end

  test "read_file for concept exercise returns correct README.md file" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = solution.read_file('README.md')
    expected = <<~EXPECTED.strip
      # Strings

      Welcome to Strings on Exercism's Ruby Track.
      If you need help running the tests or submitting your code, check out `HELP.md`.
      If you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)

      ## Introduction

      A `String` in Ruby is an object that holds and manipulates an arbitrary sequence of bytes, typically representing characters. Strings are manipulated by calling the string's methods.

      ## Instructions

      In this exercise you'll be processing log-lines.

      Each log line is a string formatted as follows: `"[<LEVEL>]: <MESSAGE>"`.

      There are three different log levels:

      - `INFO`
      - `WARNING`
      - `ERROR`

      You have three tasks, each of which will take a log line and ask you to do something with it.

      ## 1. Get message from a log line

      Implement the `LogLineParser.message` method to return a log line's message:

      ```ruby
      LogLineParser.message('[ERROR]: Invalid operation')
      // Returns: "Invalid operation"
      ```

      Any leading or trailing white space should be removed:

      ```ruby
      LogLineParser.message('[WARNING]:  Disk almost full\\r\\n')
      // Returns: "Disk almost full"
      ```

      ## 2. Get log level from a log line

      Implement the `LogLineParser.log_level` method to return a log line's log level, which should be returned in lowercase:

      ```ruby
      LogLineParser.log_level('[ERROR]: Invalid operation')
      // Returns: "error"
      ```

      ## 3. Reformat a log line

      Implement the `LogLineParser.reformat` method that reformats the log line, putting the message first and the log level after it in parentheses:

      ```ruby
      LogLineParser.reformat('[INFO]: Operation completed')
      // Returns: "Operation completed (info)"
      ```

      ## Source

      ### Created by

      - @pvcarrera
    EXPECTED

    assert_equal expected, contents
  end

  test "read_file for practice exercise with hints returns correct README.md file" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = solution.read_file('README.md')
    expected = <<~EXPECTED.strip
      # Bob

      Welcome to Bob on Exercism's Ruby Track.
      If you need help running the tests or submitting your code, check out `HELP.md`.
      If you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)

      ## Introduction

      Introduction for bob

      Extra introduction for bob

      ## Instructions

      Instructions for bob

      Extra instructions for bob

      ## Source

      ### Created by

      - @erikschierboom

      ### Contributed to by

      - @ihid

      ### Based on

      Inspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial. - http://pine.fm/LearnToProgram/?Chapter=06
    EXPECTED
    assert_equal expected, contents
  end

  test "read_file for concept exercise returns correct HELP.md file" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = solution.read_file('HELP.md')
    expected = <<~EXPECTED.strip
      # Help

      ## Running the tests

      Run the tests using `ruby test`.

      ## Submitting your solution

      You can submit your solution using the `exercism submit log_line_parser.rb` command.
      This command will upload your solution to the Exercism website and print the solution page's URL.

      It's possible to submit an incomplete solution which allows you to:

      - See how others have completed the exercise
      - Request help from a mentor

      ## Need to get help?

      If you'd like help solving the exercise, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - The [Ruby track's programming category on the forum](https://forum.exercism.org/c/programming/ruby)
      - [Exercism's programming category on the forum](https://forum.exercism.org/c/programming/5)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)

      Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.

      Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal expected, contents
  end

  test "read_file for practice exercise returns correct HELP.md file" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = solution.read_file('HELP.md')
    expected = <<~EXPECTED.strip
      # Help

      ## Running the tests

      Run the tests using `ruby test`.

      ## Submitting your solution

      You can submit your solution using the `exercism submit bob.rb` command.
      This command will upload your solution to the Exercism website and print the solution page's URL.

      It's possible to submit an incomplete solution which allows you to:

      - See how others have completed the exercise
      - Request help from a mentor

      ## Need to get help?

      If you'd like help solving the exercise, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - The [Ruby track's programming category on the forum](https://forum.exercism.org/c/programming/ruby)
      - [Exercism's programming category on the forum](https://forum.exercism.org/c/programming/5)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)

      Should those resources not suffice, you could submit your (incomplete) solution to request mentoring.

      Stuck? Try the Ruby gitter channel.
    EXPECTED
    assert_equal expected, contents
  end

  test "read_file for concept exercise returns correct HINTS.md file" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = solution.read_file('HINTS.md')
    expected = <<~EXPECTED.strip
      # Hints

      ## General

      - The [rubymostas strings guide][ruby-for-beginners.rubymonstas.org-strings] has a nice introduction to Ruby strings.
      - The `String` object has many useful [built-in methods][docs-string-methods].

      ## 1. Get message from a log line

      - There are different ways to search for text in a string, which can be found on the [Ruby language official documentation][docs-string-methods].
      - There are [built in methods][strip-white-space] to strip white space.

      ## 2. Get log level from a log line

      - Ruby `String` objects have a [method][downcase] to perform this operation.

      ## 3. Reformat a log line

      - There are several ways to [concatenate strings][ruby-for-beginners.rubymonstas.org-strings], but the preferred one is usually [string interpolation][ruby-for-beginners.rubymonstas.org-strings]

      [ruby-for-beginners.rubymonstas.org-strings]: http://ruby-for-beginners.rubymonstas.org/built_in_classes/strings.html
      [ruby-for-beginners.rubymonstas.org-interpolation]: http://ruby-for-beginners.rubymonstas.org/bonus/string_interpolation.html
      [docs-string-methods]: https://ruby-doc.org/core-2.7.0/String.html
      [strip-white-space]: https://ruby-doc.org/core-2.7.0/String.html#method-i-strip
      [downcase]: https://ruby-doc.org/core-2.7.0/String.html#method-i-downcase
    EXPECTED
    assert_equal expected, contents
  end

  test "read_file for practice exercise returns correct HINTS.md file" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = solution.read_file('HINTS.md')
    expected = <<~EXPECTED.strip
      # Hints

      ## General

      - There are many useful string methods built-in
    EXPECTED
    assert_equal expected, contents
  end

  test "read_file for concept exercise returns correct .exercism/config.json file" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    contents = JSON.parse(solution.read_file('.exercism/config.json'))
    expected = JSON.parse({
      blurb: "Like puppets on a...",
      authors: ["pvcarrera"],
      files: {
        solution: ["log_line_parser.rb"],
        test: ["log_line_parser_test.rb"],
        exemplar: [".meta/exemplar.rb"]
      }
    }.to_json)
    assert_equal expected, contents
  end

  test "read_file for practice exercise returns correct .exercism/config.json file" do
    exercise = create :practice_exercise
    solution = create(:practice_solution, exercise:)

    contents = JSON.parse(solution.read_file('.exercism/config.json'))
    expected = JSON.parse({
      blurb: "Hey Bob!",
      version: "15.8.12",
      files: {
        solution: ["bob.rb"],
        test: ["bob_test.rb"],
        example: [".meta/example.rb"]
      },
      authors: ["erikschierboom"],
      contributors: ["ihid"],
      source: "Inspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial.",
      source_url: "http://pine.fm/LearnToProgram/?Chapter=06"
    }.
    to_json)
    assert_equal expected, contents
  end

  test "in_progress_mentor_discussion" do
    solution = create :concept_solution

    # No discussion
    assert_nil solution.reload.in_progress_mentor_discussion

    # In progress discussion
    discussion = create(:mentor_discussion, solution:)
    assert_equal discussion, Solution.find(solution.id).in_progress_mentor_discussion

    # Finished discussion
    discussion.update!(status: :finished)
    assert_nil Solution.find(solution.id).in_progress_mentor_discussion
  end

  test "has_pending_mentoring_requests" do
    solution = create :concept_solution

    # No request
    refute solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # No lock
    request = create(:mentor_request, solution:)
    assert solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # Current Lock
    create(:mentor_request_lock, request:)
    refute solution.reload.has_unlocked_pending_mentoring_request?
    assert solution.reload.has_locked_pending_mentoring_request?

    # Fulfilled
    request.update(status: :fulfilled)
    refute solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # Cancelled
    request.update(status: :cancelled)
    refute solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?
  end

  # The order of the sub-tests in this test are deliberately
  # set to ensure that things are checked in a safe way.
  test "update_mentoring_status!" do
    solution = create :concept_solution
    assert_equal :none, solution.mentoring_status

    request = create(:mentor_request, solution:)
    assert_equal :requested, solution.mentoring_status

    discussion = create(:mentor_discussion, solution:)
    request.fulfilled!
    assert_equal :in_progress, solution.mentoring_status

    discussion.update(status: :awaiting_student)
    assert_equal :in_progress, solution.mentoring_status

    discussion.update(status: :awaiting_mentor)
    assert_equal :in_progress, solution.mentoring_status

    discussion.update(status: :mentor_finished)
    assert_equal :in_progress, solution.mentoring_status

    discussion.update(status: :finished)
    assert_equal :finished, solution.mentoring_status

    discussion.destroy
    request.cancelled!
    assert_equal :none, solution.mentoring_status
  end

  test "latest iteration does not include deleted" do
    solution = create :concept_solution
    create(:iteration, solution:)
    iteration = create(:iteration, solution:)
    create :iteration, solution:, deleted_at: Time.current

    assert_equal iteration, solution.latest_iteration
  end

  test "touches user_track" do
    freeze_time do
      old_time = Time.current - 1.week
      solution = create :concept_solution
      user_track = create :user_track, track: solution.track, user: solution.user
      assert_equal user_track, solution.user_track # Sanity

      user_track.update_column(:updated_at, old_time)

      assert_equal old_time, user_track.reload.updated_at # Sanity
      solution.touch
      assert_equal Time.current, user_track.reload.updated_at # Sanity
    end
  end

  test "num_iterations is updated" do
    solution = create :concept_solution
    assert_equal 0, solution.num_iterations # Sanity

    create(:iteration, solution:)
    assert_equal 1, solution.num_iterations
  end

  test "num_stars is updated" do
    solution = create :concept_solution
    assert_equal 0, solution.num_stars # Sanity

    create(:solution_star, solution:)
    assert_equal 1, solution.num_stars
  end

  test "out_of_date" do
    exercise = create :concept_exercise
    solution = create(:concept_solution, exercise:)

    refute solution.out_of_date?

    solution.update(git_important_files_hash: "foobar")
    assert solution.out_of_date?
  end

  # test "tests and feedback statuses proxy to latest iteration" do
  #   solution = create :concept_solution
  #   create :iteration, solution: solution

  #   solution.latest_iteration.expects(status: :failed)

  #   assert_equal :failed, solution.status
  # end

  test "git_important_files_sha is set to exercise's git_important_files_sha" do
    exercise = create :practice_exercise, slug: 'allergies', git_sha: '6f169b92d8500d9ec5f6e69d6927bf732ab5274a'
    solution = create(:practice_solution, exercise:)
    assert_equal exercise.git_important_files_hash, solution.git_important_files_hash
  end

  test "latest_submission and latest_valid_submission" do
    solution = create :practice_solution
    create :submission, solution:, tests_status: :failed
    errored = create :submission, solution:, tests_status: :errored
    exceptioned = create :submission, solution:, tests_status: :exceptioned
    cancelled = create :submission, solution:, tests_status: :cancelled

    assert_equal cancelled, solution.submissions.last
    assert_equal exceptioned, solution.latest_submission
    assert_equal errored, solution.latest_valid_submission
  end

  test "external_mentoring_request_url" do
    solution = create :practice_solution
    expected = Exercism::Routes.mentoring_external_request_url(solution.public_uuid)
    assert_equal expected, solution.external_mentoring_request_url
  end

  test "mentor_download_cmd" do
    solution = create :practice_solution
    assert_equal "exercism download --uuid=#{solution.uuid}", solution.mentor_download_cmd
  end

  test "viewable_by pivots correctly" do
    student = create :user
    mentor_1 = create :user
    mentor_2 = create :user
    user = create :user, :not_mentor

    solution = create :concept_solution, user: student

    assert solution.viewable_by?(student)
    refute solution.viewable_by?(mentor_1)
    refute solution.viewable_by?(mentor_2)
    refute solution.viewable_by?(user)
    refute solution.viewable_by?(nil)

    create(:mentor_discussion, mentor: mentor_1, solution:)
    assert solution.viewable_by?(student)
    assert solution.viewable_by?(mentor_1)
    refute solution.viewable_by?(mentor_2)
    refute solution.viewable_by?(user)
    refute solution.viewable_by?(nil)

    create :mentor_request, solution:, status: :fulfilled
    assert solution.viewable_by?(student)
    assert solution.viewable_by?(mentor_1)
    refute solution.viewable_by?(mentor_2)
    refute solution.viewable_by?(user)
    refute solution.viewable_by?(nil)

    create :mentor_request, solution:, status: :pending
    assert solution.viewable_by?(student)
    assert solution.viewable_by?(mentor_1)
    assert solution.viewable_by?(mentor_2)
    refute solution.viewable_by?(user)
    refute solution.viewable_by?(nil)

    solution.update!(published_at: Time.current)
    assert solution.viewable_by?(student)
    assert solution.viewable_by?(mentor_1)
    assert solution.viewable_by?(mentor_2)
    assert solution.viewable_by?(user)
    assert solution.viewable_by?(nil)
  end

  test "creating solution enqueues job to sync solution to search index" do
    assert_enqueued_with(job: MandateJob, args: ->(job_args) { job_args[0] == Solution::SyncToSearchIndex.name }) do
      create :practice_solution
    end
  end

  test "updating solution enqueues job to sync solution to search index" do
    solution = create :practice_solution

    assert_enqueued_with(job: MandateJob, args: [Solution::SyncToSearchIndex.name, solution]) do
      solution.update!(published_at: Time.current)
    end
  end

  test "updating solution enqueues job to queue head test run" do
    solution = create :practice_solution

    assert_enqueued_with(job: MandateJob, args: [Solution::QueueHeadTestRun.name, solution]) do
      solution.update!(published_at: Time.current)
    end
  end

  test "unlocked_help is false by default" do
    solution = create :practice_solution

    refute solution.unlocked_help?
  end
end
