require "test_helper"

class Exercise::Representation::CreateSearchIndexDocumentTest < ActiveSupport::TestCase
  test "raises without solution" do
    representation = create(:exercise_representation)

    assert_raises NoPublishedSolutionForRepresentationError do
      Exercise::Representation::CreateSearchIndexDocument.(representation)
    end
  end

  test "raises if not published" do
    representation = create(:exercise_representation)
    solution = create :practice_solution, published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    create(:iteration, solution:)

    assert_raises NoPublishedSolutionForRepresentationError do
      Exercise::Representation::CreateSearchIndexDocument.(representation)
    end
  end

  test "raises without published_iteration" do
    representation = create(:exercise_representation)
    create :practice_solution, :published, published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed

    assert_raises NoPublishedSolutionForRepresentationError do
      Exercise::Representation::CreateSearchIndexDocument.(representation)
    end
  end

  test "raises if not passing latest tests" do
    representation = create(:exercise_representation)
    solution = create :practice_solution, published_exercise_representation: representation,
      published_iteration_head_tests_status: :failed
    create(:iteration, solution:)

    assert_raises NoPublishedSolutionForRepresentationError do
      Exercise::Representation::CreateSearchIndexDocument.(representation)
    end
  end

  test "indexes representation" do
    content = "CONTENT!!"
    num_published_solutions = 20
    num_loc = 42

    oldest_solution = create(:practice_solution, :published, published_iteration_head_tests_status: :passed,
      num_loc:).tap do |solution|
      submission = create(:submission, solution:)
      create(:iteration, submission:)
    end

    prestigious_solution = create(:practice_solution, :published, published_iteration_head_tests_status: :passed).tap do |solution|
      submission = create(:submission, solution:)
      create(:iteration, submission:)
    end
    prestigious_solution.user.update!(reputation: 1234)
    create :user_arbitrary_reputation_token, user: prestigious_solution.user, track: prestigious_solution.track,
      params: { arbitrary_value: 20, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user: prestigious_solution.user, track: prestigious_solution.track,
      params: { arbitrary_value: 50, arbitrary_reason: "" }

    source_submission = create(:submission)
    create(:submission_file, submission: source_submission, content:)

    representation = create(
      :exercise_representation,
      num_published_solutions:,
      source_submission:,
      oldest_solution:,
      prestigious_solution:
    )

    expected = {
      id: representation.id,
      oldest_solution_id: oldest_solution.id,
      prestigious_solution_id: prestigious_solution.id,
      num_loc:,
      num_solutions: num_published_solutions,
      max_reputation: 20 + 50,
      tags: [],
      code: [content],
      exercise: {
        id: representation.exercise.id,
        slug: representation.exercise.slug,
        title: representation.exercise.title
      },
      track: {
        id: representation.track.id,
        slug: representation.track.slug,
        title: representation.track.title
      }
    }

    assert_equal expected, Exercise::Representation::CreateSearchIndexDocument.(representation)
  end

  test "considers tests pass if any solution's do" do
    representation = create(:exercise_representation)

    # Normal one that fails
    solution_1 = create :practice_solution, :published,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :failed
    submission = create :submission, solution: solution_1
    create(:submission_file, submission:)
    create(:iteration, submission:)

    representation.update!(oldest_solution: solution_1, prestigious_solution: solution_1)

    assert_raises NoPublishedSolutionForRepresentationError do
      Exercise::Representation::CreateSearchIndexDocument.(representation)
    end

    # Second one that does pass - any is enough
    solution_2 = create :practice_solution, :published,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed

    assert_nothing_raised do
      Exercise::Representation::CreateSearchIndexDocument.(representation)
    end

    # If none pass, but one fails, that's bad
    solution_2.update(published_iteration_head_tests_status: :queued)
    assert_raises NoPublishedSolutionForRepresentationError do
      Exercise::Representation::CreateSearchIndexDocument.(representation)
    end

    # But if all are queued, that's ok
    solution_1.update(published_iteration_head_tests_status: :queued)
    assert_nothing_raised do
      assert Exercise::Representation::CreateSearchIndexDocument.(representation)
    end
  end

  test "uses tags from last analyzed submission" do
    exercise = create :practice_exercise
    representation = create(:exercise_representation, exercise:)

    solution_1 = create :practice_solution, :published, exercise:,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    create(:iteration, solution: solution_1)
    submission_1 = create(:submission, solution: solution_1, analysis_status: :queued)
    submission_1_tags = ["construct:throw", "paradigm:object-oriented"]
    create(:submission_representation, submission: submission_1, ast_digest: representation.ast_digest)
    create(:submission_analysis, submission: submission_1, tags_data: { tags: submission_1_tags })
    representation.update!(oldest_solution: solution_1, prestigious_solution: solution_1)

    actual_tags = Exercise::Representation::CreateSearchIndexDocument.(representation)[:tags]
    assert_empty actual_tags

    solution_2 = create :practice_solution, :published, exercise:,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    create(:iteration, solution: solution_2)
    submission_2 = create(:submission, solution: solution_2, analysis_status: :completed)
    submission_2_tags = ["construct:if", "paradigm:functional"]
    create(:submission_representation, submission: submission_2, ast_digest: representation.ast_digest)
    create(:submission_analysis, submission: submission_2, tags_data: { tags: submission_2_tags })

    actual_tags = Exercise::Representation::CreateSearchIndexDocument.(representation)[:tags]
    assert_equal submission_2_tags, actual_tags

    solution_3 = create :practice_solution, :published, exercise:,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    create(:iteration, solution: solution_3)
    submission_3 = create(:submission, solution: solution_3, analysis_status: :completed)
    submission_3_tags = ["construct:while-loop", "paradigm:imperative"]
    create(:submission_representation, submission: submission_3, ast_digest: representation.ast_digest)
    create(:submission_analysis, submission: submission_3, tags_data: { tags: submission_3_tags })

    actual_tags = Exercise::Representation::CreateSearchIndexDocument.(representation)[:tags]
    assert_equal submission_3_tags, actual_tags
  end
end
