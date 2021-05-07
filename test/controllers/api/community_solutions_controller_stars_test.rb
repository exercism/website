require_relative './base_test_case'

module API
  class CommunitySolutionsControllerStarsTest < API::BaseTestCase
    guard_incorrect_token! :api_track_exercise_community_solution_star_path, args: 3, method: :post
    guard_incorrect_token! :api_track_exercise_community_solution_star_path, args: 3, method: :delete

    ##########
    # Create #
    ##########
    test "create stars solution" do
      setup_user
      solution = create :practice_solution, :published

      post api_track_exercise_community_solution_star_path(
        solution.track, solution.exercise, solution.user.handle
      ), headers: @headers, as: :json
      assert_response 204

      assert_equal 1, solution.stars.count
      assert_equal @current_user, solution.stars.first.user
    end

    ###########
    # Destroy #
    ###########
    test "destroy unstars solution" do
      setup_user
      solution = create :practice_solution, :published
      create :solution_star, solution: solution, user: @current_user
      assert_equal 1, solution.stars.count

      delete api_track_exercise_community_solution_star_path(
        solution.track, solution.exercise, solution.user.handle
      ), headers: @headers, as: :json
      assert_response 204

      assert_equal 0, solution.stars.count
    end
  end
end
