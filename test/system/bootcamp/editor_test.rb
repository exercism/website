require "application_system_test_case"

# best for initially setting content when the page loads
def change_codemirror_content(content)
  escaped_content = content.gsub("\n", "\\n").gsub('"', '\"')

  page.execute_script(%{
    const observer = new MutationObserver((mutations, obs) => {
      const lines = document.querySelectorAll('.cm-line');
      if (lines.length > 0) {
        lines.forEach(line => line.innerText = '');
        lines[lines.length - 1].innerText = "#{escaped_content}";
        obs.disconnect();
      }
    });

    observer.observe(document.body, { childList: true, subtree: true });
  })
end

# best for updating content after the page has loaded
def update_codemirror_content(content)
  escaped_content = content.gsub("\n", "\\n").gsub('"', '\"')
  page.execute_script(%{
      const lines = document.querySelectorAll('.cm-line');
      if (lines.length > 0) {
        lines.forEach(line => line.innerText = '');
        lines[lines.length - 1].innerText = "#{escaped_content}";
      }
  })
end

def check_scenarios = find("[data-ci='check-scenarios-button']").click

def toggle_information_tooltip = find("[data-ci=information-widget-toggle]").click

def scrub_to__(value)
  page.execute_script(%{
    let scrubber = document.querySelector("[data-ci='scrubber-range-input']");
    if (scrubber) {
      let previousValue = scrubber.value;

      let pointerDownEvent = new PointerEvent('pointerdown', { bubbles: true });
      scrubber.dispatchEvent(pointerDownEvent);

      let inputEvent = new Event('input', { bubbles: true });
      Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set.call(scrubber, #{value});
      scrubber.dispatchEvent(inputEvent);

      let pointerMoveEvent = new PointerEvent('pointermove', { bubbles: true });
      scrubber.dispatchEvent(pointerMoveEvent);

      let pointerUpEvent = new PointerEvent('pointerup', { bubbles: true });
      scrubber.dispatchEvent(pointerUpEvent);

      let changeEvent = new Event('change', { bubbles: true });
      scrubber.dispatchEvent(changeEvent);

      console.log(`Scrubber moved from ${previousValue} to ${scrubber.value}`);
    }
  })
end

def scrub_to(value)
  scrubber = find("[data-ci='scrubber-range-input']")

  # Get slider dimensions
  min = scrubber[:min].to_f
  max = scrubber[:max].to_f
  width = scrubber.native.rect.width

  # Convert value into pixel offset
  percent = (value - min) / (max - min)
  x_offset = (percent * width).to_i - (width / 2) # Center-based calculation

  # Perform the drag action
  page.driver.browser.action.
    click_and_hold(scrubber.native).
    move_by(x_offset, 0).
    release.
    perform
end

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

        change_codemirror_content(%{
move()
move()
move()
move()
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

        change_codemirror_content(%{
move()
move()
move()
move()
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

        change_codemirror_content(%(
function even_or_odd with number do
  if number % 2 equals 0 do
    return "Even"
  else do
    return "Odd"
  end
end
        ))

        find("[data-ci='check-scenarios-button']").click
        refute_selector(".c-scenario.fail")
        refute_selector(".c-scenario.pending")
        assert_selector(".test-button.pass")
        assert_selector(".c-scenario.pass")

        assert_text "Nice work!"
        assert_selector ".solve-exercise-page-react-modal-content"
        click_on "Tweak further"
        refute_selector ".solve-exercise-page-react-modal-content"
      end
    end

    test "doesnt show modal on io test when tasks are undone" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
  return "Even"
end))

        find("[data-ci='check-scenarios-button']").click
        assert_selector(".c-scenario.fail")
        refute_selector(".c-scenario.pending")
        refute_selector(".c-scenario.pass")

        refute_text "Nice work!"
        refute_selector ".solve-exercise-page-react-modal-content"
      end
    end

    test "shows modal on io test when after reiterating exercise correctly" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd

      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
  return "Even"
end))

        find("[data-ci='check-scenarios-button']").click
        assert_selector(".c-scenario.fail")
        refute_selector(".c-scenario.pass")

        refute_text "Nice work!"
        refute_selector ".solve-exercise-page-react-modal-content"

        change_codemirror_content(%(
          function even_or_odd with number do
            if number % 2 equals 0 do
              return "Even"
            else do
              return "Odd"
            end
          end
                  ))
        find("[data-ci='check-scenarios-button']").click

        assert_text "Nice work!"
        assert_selector ".solve-exercise-page-react-modal-content"
        refute_selector(".c-scenario.fail")
        assert_selector(".c-scenario.pass")
      end
    end

    test "shows first failing case" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
  return "Even"
end))
        find("[data-ci='check-scenarios-button']").click
        assert_selector(".c-scenario.fail")
        refute_selector(".c-scenario.pass")
        assert find(".test-button.fail.selected").has_text?("3")
      end
    end

    test "stays on inspected failing scenario after rerunning code" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
  return "Even"
end))
        check_scenarios
        assert_selector(".c-scenario.fail")
        refute_selector(".c-scenario.pass")
        assert find(".test-button.fail.selected").has_text?("3")
        find(".test-button.fail", text: "4").click
        check_scenarios
        assert find(".test-button.fail.selected").has_text?("4")
      end
    end

    test "selects last scenario on passing tests" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
  return "Even"
end))
        check_scenarios
        assert_selector(".c-scenario.fail")
        refute_selector(".c-scenario.pass")
        assert find(".test-button.fail.selected").has_text?("3")
        find(".test-button.fail", text: "4").click
        check_scenarios
        assert find(".test-button.fail.selected").has_text?("4")

        change_codemirror_content(%(
          function even_or_odd with number do
            if number % 2 equals 0 do
              return "Even"
            else do
              return "Odd"
            end
          end
                  ))
        check_scenarios
        refute_selector('.test-button.fail')
        assert find(".test-button.pass.selected").has_text?("5")
      end
    end

    test "shows info-widget with error on erronous code" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
          run_this_thing()
  return "Even"
end))
        check_scenarios

        assert_text "[Your function didn't return anything]"
        assert_text "Jiki couldn't find a function with the name run_this_thing."
        assert_selector ".information-tooltip.error"
      end
    end

    test "hides info-widget on editor change" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
          run_this_thing()
  return "Even"
end))
        check_scenarios

        assert_text "Your function didn't return anything"
        assert_text "Jiki couldn't find a function with the name run_this_thing."
        assert_selector ".information-tooltip.error"

        update_codemirror_content(%(function even_or_odd with number do
return "Even"
end))
        refute_text "Jiki couldn't find a function with the name run_this_thing."
        refute_selector ".information-tooltip.error"
      end
    end

    test "can inspect line with information widget" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
  set this to 5
  return "Even"
end))
        check_scenarios

        find("[data-ci=information-widget-toggle]").click

        assert_text "This created a new variable called this and sets its value to 5."
        assert_selector ".information-tooltip.description"
      end
    end

    test "can scrub between animation timeline frames" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :manual_solve
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(move()
turn_right()
))
        check_scenarios

        toggle_information_tooltip
        assert_selector ".information-tooltip.description"
        assert_text "This called the turn_right function."
        scrub_to(0)
        assert_text "This called the move function."
      end
    end

    test "can scrub between io frames" do
      user = create(:user, bootcamp_attendee: true)
      exercise = create :bootcamp_exercise, :even_or_odd
      use_capybara_host do
        sign_in!(user)
        visit bootcamp_project_exercise_url(exercise.project, exercise)

        change_codemirror_content(%(function even_or_odd with number do
          set this to 5
          return "Even"
        end))

        check_scenarios

        toggle_information_tooltip
        assert_selector ".information-tooltip.description"
        assert_text "This created a new variable called this and sets its value to 5."
        scrub_to(1)
        assert_text "This returned the value of undefined, which in this case is Even."
      end
    end
  end
end
