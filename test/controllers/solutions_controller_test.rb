require "test_helper"

class SolutionsControllerTest < ActionDispatch::IntegrationTest
  test "legacy_show: /solutions/:uuid" do
    assert_recognizes(
      { controller: 'solutions', action: 'legacy_show', uuid: "foobar" },
      "/solutions/foobar"
    )
  end

  test "legacy_show: /my/solutions/:uuid" do
    assert_recognizes(
      { controller: 'solutions', action: 'legacy_show', uuid: "foobar" },
      "/my/solutions/foobar"
    )
  end

  test "legacy_show: /mentor/solutions/:uuid" do
    assert_recognizes(
      { controller: 'solutions', action: 'legacy_show', uuid: "foobar" },
      "/mentor/solutions/foobar"
    )
  end

  test "legacy_show with user's solution" do
    user = create :user
    solution = create :concept_solution, user: user
    sign_in!(user)

    get "/solutions/#{solution.uuid}"
    assert_redirected_to "https://test.exercism.io/tracks/#{solution.track.slug}/exercises/#{solution.exercise.slug}"
  end

  test "legacy_show with logged-in published solution" do
    # TODO: Once we have devise, move this below next to the get
    sign_in!

    solution = create :concept_solution, published_at: Time.current

    get "/solutions/#{solution.uuid}"

    assert_redirected_to "https://test.exercism.io/tracks/#{solution.track.slug}/exercises/#{solution.exercise.slug}/solutions/#{solution.user.handle}" # rubocop:disable Layout/LineLength
  end

  test "legacy_show with logged-out published solution" do
    # TODO: Remove this when we add Devise
    create :user

    solution = create :concept_solution, published_at: Time.current

    get "/solutions/#{solution.uuid}"

    assert_redirected_to "https://test.exercism.io/tracks/#{solution.track.slug}/exercises/#{solution.exercise.slug}/solutions/#{solution.user.handle}" # rubocop:disable Layout/LineLength
  end

  test "legacy_show with logged-in non-published solution" do
    # TODO: Once we have devise, move this below next to the get
    sign_in!

    solution = create :concept_solution, published_at: nil

    assert_raises ActiveRecord::RecordNotFound do
      get "/solutions/#{solution.uuid}"
    end
  end

  test "legacy_show with logged-out non-published solution" do
    # TODO: Remove this when we add Devise
    create :user

    solution = create :concept_solution, published_at: nil

    assert_raises ActiveRecord::RecordNotFound do
      get "/solutions/#{solution.uuid}"
    end
  end
end
