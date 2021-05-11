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
      refute solution.uuid.nil?
    end

    test "#{solution_type}: doesn't override uuid" do
      uuid = "foobar"
      solution = build solution_type, uuid: uuid
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

  test "update_git_info!" do
    solution = create :concept_solution
    solution.update!(git_sha: "foo", git_slug: "bar")

    # Sanity
    assert_equal "foo", solution.git_sha
    assert_equal "bar", solution.git_slug

    solution.update_git_info!
    assert_equal solution.exercise.git_sha, solution.git_sha
    assert_equal solution.exercise.slug, solution.git_slug
  end

  test "status" do
    solution = create :concept_solution
    assert_equal :started, solution.reload.status.to_sym

    create :iteration, solution: solution
    assert_equal :iterated, solution.reload.status.to_sym

    solution.update!(completed_at: Time.current)
    assert_equal :completed, solution.reload.status.to_sym

    solution.update!(published_at: Time.current)
    assert_equal :published, solution.reload.status.to_sym
  end

  test "published_iterations" do
    solution = create :concept_solution
    it_1 = create :iteration, solution: solution
    it_2 = create :iteration, solution: solution

    assert_empty solution.published_iterations

    solution.update(published_at: Time.current)
    assert_equal [it_1, it_2], solution.published_iterations

    solution.update(published_iteration: it_2)
    assert_equal [it_2], solution.published_iterations
  end

  test "downloaded?" do
    refute create(:concept_solution, downloaded_at: nil).downloaded?
    assert create(:concept_solution, downloaded_at: Time.current).downloaded?
  end

  test "iterated?" do
    solution = create :concept_solution
    refute solution.iterated?

    create :iteration, solution: solution
    assert solution.reload.iterated?
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
    create :concept_solution, user: user
    create :concept_solution, exercise: exercise
    solution = create :concept_solution, user: user, exercise: exercise

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
    # TODO: Readd this once we stop using HEAD for all the git stuff
    # Use an old sha to check the right content is returned.
    skip
    solution = create :practice_solution
    assert_equal instructions, solution.instructions
  end

  test "#exercise_solution_files returns exercise files" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    expected_files = ["log_line_parser.rb"]
    assert_equal expected_files, solution.exercise_solution_files.keys
    assert solution.exercise_solution_files["log_line_parser.rb"].start_with?("module LogLineParser")
  end

  test "read_file for concept exercise returns exercise file" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    contents = solution.read_file('log_line_parser.rb')
    assert contents.start_with?('module LogLineParser')
  end

  test "read_file for practice exercise returns exercise file" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise

    contents = solution.read_file('bob.rb')
    assert contents.start_with?('stub content')
  end

  test "read_file for concept exercise returns correct README.md file" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    contents = solution.read_file('README.md')
    expected = "# Strings\n\nWelcome to Strings on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\nIf you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)\n\n## Introduction\n\nA `String` in Ruby is an object that holds and manipulates an arbitrary sequence of bytes, typically representing characters. Strings are manipulated by calling the string's methods.\n\n## Instructions\n\nIn this exercise you'll be processing log-lines.\n\nEach log line is a string formatted as follows: `\"[<LEVEL>]: <MESSAGE>\"`.\n\nThere are three different log levels:\n\n- `INFO`\n- `WARNING`\n- `ERROR`\n\nYou have three tasks, each of which will take a log line and ask you to do something with it.\n\n## 1. Get message from a log line\n\nImplement the `LogLineParser.message` method to return a log line's message:\n\n```ruby\nLogLineParser.message('[ERROR]: Invalid operation')\n// Returns: \"Invalid operation\"\n```\n\nAny leading or trailing white space should be removed:\n\n```ruby\nLogLineParser.message('[WARNING]:  Disk almost full\\r\\n')\n// Returns: \"Disk almost full\"\n```\n\n## 2. Get log level from a log line\n\nImplement the `LogLineParser.log_level` method to return a log line's log level, which should be returned in lowercase:\n\n```ruby\nLogLineParser.log_level('[ERROR]: Invalid operation')\n// Returns: \"error\"\n```\n\n## 3. Reformat a log line\n\nImplement the `LogLineParser.reformat` method that reformats the log line, putting the message first and the log level after it in parentheses:\n\n```ruby\nLogLineParser.reformat('[INFO]: Operation completed')\n// Returns: \"Operation completed (info)\"\n```\n\n## Source\n\n### Created by\n\n- @pvcarrera" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "read_file for practice exercise with hints returns correct README.md file" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise

    contents = solution.read_file('README.md')
    expected = "# Bob\n\nWelcome to Bob on Exercism's Ruby Track.\nIf you need help running the tests or submitting your code, check out `HELP.md`.\nIf you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)\n\n## Introduction\n\nIntroduction for bob\n\nExtra introduction for bob\n\n## Instructions\n\nInstructions for bob\n\nExtra instructions for bob\n\n## Source\n\n### Created by\n\n- @erikschierboom\n\n### Contributed to by\n\n- @ihid\n\n### Based on\n\nInspired by the 'Deaf Grandma' exercise in Chris Pine's Learn to Program tutorial. - http://pine.fm/LearnToProgram/?Chapter=06" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "read_file for concept exercise returns correct HELP.md file" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    contents = solution.read_file('HELP.md')
    expected = "# Help\n\n## Running the tests\n\nRun the tests using `ruby test`.\n\n## Submitting your solution\n\nTODO\n\n## Need to get help?\n\nTODO\n\nStuck? Try the Ruby gitter channel." # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "read_file for practice exercise returns correct HELP.md file" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise

    contents = solution.read_file('HELP.md')
    expected = "# Help\n\n## Running the tests\n\nRun the tests using `ruby test`.\n\n## Submitting your solution\n\nTODO\n\n## Need to get help?\n\nTODO\n\nStuck? Try the Ruby gitter channel." # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "read_file for concept exercise returns correct HINTS.md file" do
    exercise = create :concept_exercise
    solution = create :concept_solution, exercise: exercise

    contents = solution.read_file('HINTS.md')
    expected = "# Hints\n\n## General\n\n- The [rubymostas strings guide][ruby-for-beginners.rubymonstas.org-strings] has a nice introduction to Ruby strings.\n- The `String` object has many useful [built-in methods][docs-string-methods].\n\n## 1. Get message from a log line\n\n- There are different ways to search for text in a string, which can be found on the [Ruby language official documentation][docs-string-methods].\n- There are [built in methods][strip-white-space] to strip white space.\n\n## 2. Get log level from a log line\n\n- Ruby `String` objects have a [method][downcase] to perform this operation.\n\n## 3. Reformat a log line\n\n- There are several ways to [concatenate strings][ruby-for-beginners.rubymonstas.org-strings], but the preferred one is usually [string interpolation][ruby-for-beginners.rubymonstas.org-strings]\n\n[ruby-for-beginners.rubymonstas.org-strings]: http://ruby-for-beginners.rubymonstas.org/built_in_classes/strings.html\n[ruby-for-beginners.rubymonstas.org-interpolation]: http://ruby-for-beginners.rubymonstas.org/bonus/string_interpolation.html\n[docs-string-methods]: https://ruby-doc.org/core-2.7.0/String.html\n[strip-white-space]: https://ruby-doc.org/core-2.7.0/String.html#method-i-strip\n[downcase]: https://ruby-doc.org/core-2.7.0/String.html#method-i-downcase" # rubocop:disable Layout/LineLength
    assert_equal expected, contents
  end

  test "read_file for practice exercise returns correct HINTS.md file" do
    exercise = create :practice_exercise
    solution = create :practice_solution, exercise: exercise

    contents = solution.read_file('HINTS.md')
    expected = "# Hints\n\n## General\n\n- There are many useful string methods built-in"
    assert_equal expected, contents
  end

  test "in_progress_mentor_discussion" do
    solution = create :concept_solution

    # No discussion
    assert_nil solution.reload.in_progress_mentor_discussion

    # In progress discussion
    discussion = create :mentor_discussion, solution: solution
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
    request = create :mentor_request, solution: solution
    assert solution.reload.has_unlocked_pending_mentoring_request?
    refute solution.reload.has_locked_pending_mentoring_request?

    # Current Lock
    create :mentor_request_lock, request: request
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

    request = create :mentor_request, solution: solution
    assert_equal :requested, solution.mentoring_status

    discussion = create :mentor_discussion, solution: solution
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

  test "latest iteration" do
    solution = create :concept_solution
    create :iteration, solution: solution
    iteration = create :iteration, solution: solution

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

    create :iteration, solution: solution
    assert_equal 1, solution.num_iterations
  end

  test "num_stars is updated" do
    solution = create :concept_solution
    assert_equal 0, solution.num_stars # Sanity

    create :solution_star, solution: solution
    assert_equal 1, solution.num_stars
  end

  # test "tests and feedback statuses proxy to latest iteration" do
  #   solution = create :concept_solution
  #   create :iteration, solution: solution

  #   solution.latest_iteration.expects(status: :failed)

  #   assert_equal :failed, solution.status
  # end
end
