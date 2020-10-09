require "application_system_test_case"

module Components
  module Student
    class TracksListTest < ApplicationSystemTestCase
      def setup
        super

        # This component uses the API, which requires authentication.
        sign_in!
      end

      test "renders correctly for unjoined track" do
        create :track,
          title: "Ruby",
          tags: ["Foo:Bar", "Abc:Xyz"]

        visit test_components_student_tracks_list_url

        assert_html '
          <a class="c-track" href="https://test.exercism.io/tracks/ruby">
            <div class="content">
              <img class="c-track-icon"
                   src="https://assets.exercism.io/tracks/ruby-hex-white.png"
                   alt="icon for Ruby track">
                <div class="info">
                  <div class="s-flex s-items-center s-mb-8">
                    <h3 class="title">Ruby</h3>
                  </div>
                  <ul class="counts">
                    <li>0/0 concepts</li>
                    <li>0/0 exercises</li>
                  </ul>
                  <ul class="tags">
                    <li>Bar</li>
                    <li>Xyz</li>
                  </ul>
                </div>
                <i>›</i>
              </img>
            </div>
          </a>
        ', within: ".c-tracks-list"
      end

      test "renders correctly for joined track" do
        track = create :track,
          title: "Ruby",
          tags: ["Foo:Bar", "Abc:Xyz"]
        concept_exercises = Array.new(3).map { create :concept_exercise, track: track }
        practice_exercises = Array.new(4).map { create :practice_exercise, track: track }
        create :user_track, track: track, user: @current_user
        concept_exercises.sample(1).map { |ex| create :concept_solution, user: @current_user, exercise: ex }
        practice_exercises.sample(2).map { |ex| create :practice_solution, user: @current_user, exercise: ex }

        visit test_components_student_tracks_list_url

        assert_html '
          <a class="c-track" href="https://test.exercism.io/tracks/ruby">
            <div class="content">
              <img class="c-track-icon"
                   src="https://assets.exercism.io/tracks/ruby-hex-white.png"
                   alt="icon for Ruby track">
                <div class="info">
                  <div class="s-flex s-items-center s-mb-8">
                    <h3 class="title">Ruby</h3>
                    <div class="joined">Joined</div>
                  </div>
                  <ul class="counts">
                    <li>1/3 concepts</li>
                    <li>2/4 exercises</li>
                  </ul>
                  <ul class="tags">
                    <li>Bar</li>
                    <li>Xyz</li>
                  </ul>
                </div>
                <i>›</i>
              </img>
              <div class="progress-bar">
                <div class="cp" style="width: 14.2857%;"></div>
                <div class="ucp" style="width: 28.5714%;"></div>
                <div class="ce" style="width: 28.5714%;"></div>
                <div class="uce" style="width: 28.5714%;"></div>
              </div>
            </div>
          </a>
        ', within: ".c-tracks-list"
      end

      test "filter by track title" do
        create :track, title: "Ruby"
        create :track, title: "Go"

        visit test_components_student_tracks_list_url
        fill_in "Search language tracks", with: "Go"

        assert_selector(".c-tracks-list .c-track", count: 1)
        assert_text "Go", within: ".c-track"
      end

      test "filter by status" do
        create :track, title: "Ruby"
        go = create :track, title: "Go"
        create :user_track, track: go, user: @current_user

        visit test_components_student_tracks_list_url
        click_on "Joined20", exact: true

        assert_selector(".c-tracks-list .c-track", count: 1)
        assert_text "Go", within: ".c-track"
      end

      test "filter by tag" do
        create :track, title: "Ruby", tags: ["Paradigm:Object-oriented", "Typing:Dynamic"]
        create :track, title: "Go", tags: ["Paradigm:Object-oriented", "Typing:Static"]

        visit test_components_student_tracks_list_url
        click_on "Filter by"
        check "Object-oriented"
        check "Dynamic"
        click_on "Apply"

        assert_text "Showing 1 track"
        assert_selector(".c-tracks-list .c-track", count: 1)
        assert_text "Ruby", within: ".c-track"
      end

      test "resets filters" do
        create :track, title: "Ruby", tags: ["Paradigm:Object-oriented", "Typing:Dynamic"]
        create :track, title: "Go", tags: ["Paradigm:Object-oriented", "Typing:Static"]

        visit test_components_student_tracks_list_url
        click_on "Filter by"
        check "Object-oriented"
        check "Dynamic"
        click_on "Apply"
        click_on "Reset filters"

        assert_text "Exercism's Language Tracks"
        assert_text "Ruby"
        assert_text "Go"
      end

      test "shows empty state" do
        visit test_components_student_tracks_list_url

        assert_text "No results found"
      end

      test "shows loading state" do
        visit test_components_student_tracks_list_url
        select "Loading", from: "State"
        click_on "Submit"

        assert_text "Loading"
      end

      test "shows error state" do
        visit test_components_student_tracks_list_url
        select "Error", from: "State"
        click_on "Submit"

        assert_text "Something went wrong"
      end
    end
  end
end
