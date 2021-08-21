require "test_helper"

class LegacyControllerTest < ActionDispatch::IntegrationTest
  test "route: /solutions/:uuid" do
    assert_recognizes(
      { controller: 'legacy', action: 'solution', uuid: "foobar" },
      "/solutions/foobar"
    )
  end

  test "route: /my/solutions/:uuid" do
    assert_recognizes(
      { controller: 'legacy', action: 'my_solution', uuid: "foobar" },
      "/my/solutions/foobar"
    )
  end

  test "route: /mentor/solutions/:uuid" do
    assert_recognizes(
      { controller: 'legacy', action: 'mentor_solution', uuid: "foobar" },
      "/mentor/solutions/foobar"
    )
  end

  test "solution with user's solution" do
    user = create :user
    solution = create :concept_solution, user: user
    sign_in!(user)

    get "/my/solutions/#{solution.uuid}"
    assert_redirected_to "https://test.exercism.io/tracks/#{solution.track.slug}/exercises/#{solution.exercise.slug}"
  end

  test "solution with logged-in published solution" do
    user = create :user
    solution = create :concept_solution, published_at: Time.current

    get "/solutions/#{solution.uuid}"
    sign_in!(user)

    assert_redirected_to "https://test.exercism.io/tracks/#{solution.track.slug}/exercises/#{solution.exercise.slug}/solutions/#{solution.user.handle}" # rubocop:disable Layout/LineLength
  end

  test "solution with logged-out published solution" do
    solution = create :concept_solution, published_at: Time.current

    get "/solutions/#{solution.uuid}"

    assert_redirected_to "https://test.exercism.io/tracks/#{solution.track.slug}/exercises/#{solution.exercise.slug}/solutions/#{solution.user.handle}" # rubocop:disable Layout/LineLength
  end

  test "solution with logged-in non-published solution" do
    user = create :user

    solution = create :concept_solution, published_at: nil
    sign_in!(user)

    get "/solutions/#{solution.uuid}"
    assert_response 404
  end

  test "solution with logged-out non-published solution" do
    solution = create :concept_solution, published_at: nil

    get "/solutions/#{solution.uuid}"
    assert_response 404
  end

  test "mentor solution with discussion" do
    user = create :user
    solution = create :concept_solution
    discussion = create :mentor_discussion, solution: solution, mentor: user

    sign_in!(user)
    get "/mentor/solutions/#{solution.uuid}"
    assert_redirected_to "http://www.example.com/mentoring/discussions/#{discussion.uuid}"
  end

  test "mentor solution 404s for different mentor" do
    user = create :user
    solution = create :concept_solution
    create :mentor_discussion, solution: solution

    sign_in!(user)
    get "/mentor/solutions/#{solution.uuid}"
    assert_response 404
  end
end
