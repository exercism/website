require "test_helper"

class User::ReputationTokens::PublishedSolutionTokenTest < ActiveSupport::TestCase
  test "creates successfully" do
    student = create :user
    exercise = create :practice_exercise, difficulty: 5
    solution = create :practice_solution, user: student

    User::ReputationToken::Create.(
      student,
      :published_solution,
      solution: solution,
      level: :medium
    )

    assert_equal 1, student.reputation_tokens.size
    rt = student.reputation_tokens.first

    assert_equal User::ReputationTokens::PublishedSolutionToken, rt.class
    assert_equal "You published your solution to <strong>#{exercise.title}</strong> in <strong>#{exercise.track.title}</strong>", rt.text # rubocop:disable Layout/LineLength
    assert_equal Exercism::Routes.published_solution_url(solution), rt.internal_url
    assert_equal "#{student.id}|published_solution|Solution##{solution.id}", rt.uniqueness_key
    assert_equal :publishing, rt.category
    assert_equal :published_solution, rt.reason
    assert_equal 2, rt.value
  end
end
