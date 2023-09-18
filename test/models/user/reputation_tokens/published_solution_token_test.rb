require "test_helper"

class User::ReputationTokens::PublishedSolutionTokenTest < ActiveSupport::TestCase
  test "creates successfully" do
    student = create :user
    exercise = create :practice_exercise, difficulty: 5
    solution = create :practice_solution, :published, user: student

    User::ReputationToken::Create.(
      student,
      :published_solution,
      solution:,
      level: :medium
    )

    assert_equal 1, student.reputation_tokens.size
    rt = student.reputation_tokens.first

    assert_instance_of User::ReputationTokens::PublishedSolutionToken, rt
    assert_equal "You published your solution to <strong>#{exercise.title}</strong> in <strong>#{exercise.track.title}</strong>", rt.text # rubocop:disable Layout/LineLength
    assert_equal "#{student.id}|published_solution|Solution##{solution.id}", rt.uniqueness_key
    assert_equal :publishing, rt.category
    assert_equal :published_solution, rt.reason
    assert_equal 2, rt.value
    assert_equal solution.published_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.published_solution_url(solution), rt.rendering_data[:internal_url]
    assert_equal solution.track, rt.track
    assert_equal solution.exercise, rt.exercise
  end

  test "correct levels" do
    token = User::ReputationToken::Create.(create(:user), :published_solution, solution: create(:practice_solution, :published),
      level: :medium)
    assert_equal 2, token.value

    token = User::ReputationToken::Create.(create(:user), :published_solution, solution: create(:practice_solution, :published),
      level: :easy)
    assert_equal 1, token.value

    token = User::ReputationToken::Create.(create(:user), :published_solution, solution: create(:practice_solution, :published),
      level: :hard)
    assert_equal 3, token.value

    token = User::ReputationToken::Create.(create(:user), :published_solution, solution: create(:concept_solution, :published),
      level: :concept)
    assert_equal 1, token.value
  end
end
