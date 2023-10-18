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

    representation = create(:exercise_representation,
      num_published_solutions:)
    solution = create :practice_solution, :published,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    submission = create(:submission, solution:)
    create(:submission_file, submission:, content:)
    create(:iteration, submission:)

    expected = {
      id: representation.id,
      featured_solution_id: solution.id,
      num_loc: solution.num_loc,
      num_solutions: num_published_solutions,
      max_reputation: 0,
      tags: [],
      code: [content],
      exercise: {
        id: solution.exercise.id,
        slug: solution.exercise.slug,
        title: solution.exercise.title
      },
      track: {
        id: solution.track.id,
        slug: solution.track.slug,
        title: solution.track.title
      }
    }

    assert_equal expected, Exercise::Representation::CreateSearchIndexDocument.(representation)
  end

  test "chooses highest reputation" do
    representation = create(:exercise_representation)

    users = create_list(:user, 3) do |user|
      solution = create :practice_solution, :published, user:,
        published_exercise_representation: representation,
        published_iteration_head_tests_status: :passed
      submission = create(:submission, solution:)
      create(:submission_file, submission:, content: "foo")
      create(:iteration, submission:)
    end

    assert_equal 0, Exercise::Representation::CreateSearchIndexDocument.(representation)[:max_reputation]

    create :user_reputation_period, user: users[0], reputation: 20,
      period: :forever, category: :any, about: :track, track_id: representation.track_id
    create :user_reputation_period, user: users[1], reputation: 50,
      period: :forever, category: :any, about: :track, track_id: representation.track_id
    create :user_reputation_period, user: users[2], reputation: 13,
      period: :forever, category: :any, about: :track, track_id: representation.track_id

    assert_equal 50, Exercise::Representation::CreateSearchIndexDocument.(representation)[:max_reputation]
  end

  test "chooses correct solution" do
    representation = create(:exercise_representation)

    # Ghost user
    create :practice_solution, :published,
      user: create(:user, :ghost),
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed

    # Correct one!
    solution = create :practice_solution, :published,
      published_exercise_representation: representation,
      published_iteration_head_tests_status: :passed
    submission = create(:submission, solution:)
    create(:submission_file, submission:, content: "foo")
    create(:iteration, submission:)

    assert_equal solution.id, Exercise::Representation::CreateSearchIndexDocument.(representation)[:featured_solution_id]
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
