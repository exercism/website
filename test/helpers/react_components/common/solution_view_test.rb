require_relative "../react_component_test_case"

class ReactComponents::Common::SolutionViewTest < ReactComponentTestCase
  test "non-author viewers get the cached payload with nil links" do
    solution = create(:practice_solution, :published)
    viewer = create :user

    payload = { iterations: [], language: "ruby" }
    Solution::CacheSerializedView::Retrieve.expects(:call).with(solution).returns(payload)

    component = ReactComponents::Common::SolutionView.new(solution)
    component.stubs(current_user: viewer)

    assert_component(
      component,
      "common-solution-view",
      payload.merge(links: { change_iteration: nil, unpublish: nil })
    )
  end

  test "anonymous viewers get the cached payload" do
    solution = create(:practice_solution, :published)

    payload = { iterations: [], language: "ruby" }
    Solution::CacheSerializedView::Retrieve.expects(:call).with(solution).returns(payload)

    component = ReactComponents::Common::SolutionView.new(solution)
    component.stubs(current_user: nil)

    assert_component(
      component,
      "common-solution-view",
      payload.merge(links: { change_iteration: nil, unpublish: nil })
    )
  end

  test "the author bypasses the cache and gets live data with links" do
    solution = create(:practice_solution, :published)
    create(:iteration, solution:)

    Solution::CacheSerializedView::Retrieve.expects(:call).never

    component = ReactComponents::Common::SolutionView.new(solution)
    component.stubs(current_user: solution.user)

    assert_component(
      component,
      "common-solution-view",
      {
        iterations: SerializeIterations.(solution.iterations.not_deleted),
        language: solution.track.highlightjs_language,
        indent_size: solution.track.indent_size,
        out_of_date: solution.out_of_date?,
        published_iteration_idx: solution.published_iteration.try(:idx),
        published_iteration_idxs: solution.published_iterations.pluck(:idx),
        links: {
          change_iteration: Exercism::Routes.published_iteration_api_solution_url(solution.uuid),
          unpublish: Exercism::Routes.unpublish_api_solution_url(solution.uuid)
        }
      }
    )
  end
end
