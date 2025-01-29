require "application_system_test_case"

module Bootcamp
  class EditorTest < ApplicationSystemTestCase
    test "things render" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :penguin

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        assert_selector("#bootcamp-cm-editor")
        assert_selector("[data-ci='check-scenarios-button']")
        assert_selector("[data-ci='control-buttons']")
        assert_selector("[data-ci='task-preview']")
        refute_selector("[data-ci='inspected-test-result-view']")
        assert_selector(".page-header")
        assert_selector(".page-body-rhs")
        assert_selector(".scenario-rhs")
        assert_text "This is fun!"
      end
    end

    test "shows all scenario previews" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        assert_selector("[data-ci='task-preview']")
        assert_selector("[data-ci='preview-scenario-button']", count: 5)
        assert_text "Number 14"
        find("[data-ci='preview-scenario-button']:nth-of-type(2)").click
        assert_text "Number 28"
      end
    end

    test "sets up exercise view correctly" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :manual_solve

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        assert_selector("[data-ci='task-preview']")
        assert_text "Guide person to the end of the maze"
        assert_text "Your job is to reach the goal"
        assert_selector("[data-ci='preview-scenario-button']", count: 1)
        assert_selector(".cell", count: 49)
        assert_selector(".character")
      end
    end

    test "shows failing tests state" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :manual_solve

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        find("[data-ci='check-scenarios-button']").click
        assert_selector(".test-button.fail")
        assert_selector(".c-scenario.fail")
        assert_text "Uh Oh. You didn't reach the end of the maze. "
      end
    end

    test "shows passing tests state" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :manual_solve

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        page.execute_script(%{
          const observer = new MutationObserver((mutations, obs) => {
            const ll = document.querySelector('.cm-line:last-of-type');
            if (ll) {
              ll.innerText = '\\nmove()\\nmove()\\nmove()\\nmove()';
              obs.disconnect();
              }
              });

              observer.observe(document.body, { childList: true, subtree: true });
              })

        find("[data-ci='check-scenarios-button']").click
        refute_selector(".c-scneario.fail")
        refute_selector(".c-scneario.pending")
        assert_selector(".test-button.pass")
        assert_selector(".c-scenario.pass")
      end
    end

    test "shows modal on passing all tests and finishing timeline then tweaks further" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :manual_solve

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        page.execute_script(%{
          const observer = new MutationObserver((mutations, obs) => {
            const ll = document.querySelector('.cm-line:last-of-type');
            if (ll) {
              ll.innerText = '\\nmove()\\nmove()\\nmove()\\nmove()';
              obs.disconnect();
              }
              });

              observer.observe(document.body, { childList: true, subtree: true });
          })

        find("[data-ci='check-scenarios-button']").click

        scrubber = find("[data-ci='scrubber-range-input']")
        refute_equal scrubber.value, scrubber["max"]
        refute_selector(".solve-exercise-page-react-modal-content")
        sleep 1.5
        assert_equal scrubber.value, scrubber["max"]
        assert_selector(".solve-exercise-page-react-modal-content")

        assert_text "Nice work!"
        assert_selector ".solve-exercise-page-react-modal-content"
        click_on "Tweak further"
        refute_selector ".solve-exercise-page-react-modal-content"
      end
    end

    test "shows modal on io test when all tasks are done" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        page.execute_script(%{
          const observer = new MutationObserver((mutations, obs) => {
            const ll = document.querySelector('.cm-line:last-of-type');
            if (ll) {
              ll.innerText = `
function even_or_odd with number do
  if number % 2 equals 0 do
    return "Even"
  else do
    return "Odd"
  end
end`;
              obs.disconnect();
              }
              });

              observer.observe(document.body, { childList: true, subtree: true });
              })

        find("[data-ci='check-scenarios-button']").click
        refute_selector(".c-scneario.fail")
        refute_selector(".c-scneario.pending")
        assert_selector(".test-button.pass")
        assert_selector(".c-scenario.pass")

        assert_text "Nice work!"
        assert_selector ".solve-exercise-page-react-modal-content"
        click_on "Tweak further"
        refute_selector ".solve-exercise-page-react-modal-content"
      end
    end
  end
end
