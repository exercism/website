require_relative "../react_component_test_case"

module ReactComponents::Dropdowns
  class TrackMenuTest < ReactComponentTestCase
    test "external course" do
      track = create :track
      track.expects(:course?).never

      component = render(ReactComponents::Dropdowns::TrackMenu.new(track))
      assert_component component,
        "dropdowns-track-menu",
        {
          track: SerializeTrack.(track, UserTrack::External.new(track)),
          links: {
            repo: track.repo_url,
            documentation: Exercism::Routes.track_docs_url(track)
          }
        }
    end

    test "joined course in learning mode" do
      track = create :track
      track.expects(course?: true)
      user = create :user
      user_track = create :user_track, track: track, user: user

      component = ReactComponents::Dropdowns::TrackMenu.new(track)
      component.stubs(current_user: user)

      assert_component render(component),
        "dropdowns-track-menu",
        {
          track: SerializeTrack.(track, user_track),
          links: {
            repo: track.repo_url,
            documentation: Exercism::Routes.track_docs_url(track),
            activate_practice_mode: Exercism::Routes.activate_practice_mode_api_track_url(track),
            activate_learning_mode: nil,
            reset: Exercism::Routes.reset_api_track_url(track),
            leave: Exercism::Routes.leave_api_track_url(track)

          }
        }
    end

    test "joined course in practice mode" do
      track = create :track
      track.expects(course?: true)
      user = create :user
      user_track = create :user_track, track: track, user: user, practice_mode: true

      component = ReactComponents::Dropdowns::TrackMenu.new(track)
      component.stubs(current_user: user)

      assert_component render(component),
        "dropdowns-track-menu",
        {
          track: SerializeTrack.(track, user_track),
          links: {
            repo: track.repo_url,
            documentation: Exercism::Routes.track_docs_url(track),
            activate_practice_mode: nil,
            activate_learning_mode: Exercism::Routes.activate_learning_mode_api_track_url(track),
            reset: Exercism::Routes.reset_api_track_url(track),
            leave: Exercism::Routes.leave_api_track_url(track)

          }
        }
    end

    test "joined non-course track" do
      track = create :track
      track.expects(course?: false)
      user = create :user
      user_track = create :user_track, track: track, user: user, practice_mode: true

      component = ReactComponents::Dropdowns::TrackMenu.new(track)
      component.stubs(current_user: user)

      assert_component render(component),
        "dropdowns-track-menu",
        {
          track: SerializeTrack.(track, user_track),
          links: {
            repo: track.repo_url,
            documentation: Exercism::Routes.track_docs_url(track),
            reset: Exercism::Routes.reset_api_track_url(track),
            leave: Exercism::Routes.leave_api_track_url(track)

          }
        }
    end
  end
end
