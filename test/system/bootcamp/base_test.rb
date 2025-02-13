require "application_system_test_case"

module Bootcamp
  class BaseTest < ApplicationSystemTestCase
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

    def remove_editor_lines
      page.execute_script(%{document.querySelectorAll('.cm-line').forEach(line => line.remove());})
    end

    def mark_modal_as_shown(id)
      page.execute_script("localStorage.setItem('bootcamp-exercise-#{id}', JSON.stringify({wasFinishLessonModalShown: true}));")
    end

    def select_scenario(number)
      find("[data-ci='test-selector-button']:nth-of-type(#{number})").click
    end

    def select_scenario_preview(number)
      find("[data-ci='preview-scenario-button']:nth-of-type(#{number})").click
    end

    def check_scenarios = find("[data-ci='check-scenarios-button']").click

    def toggle_information_tooltip = find("[data-ci=information-widget-toggle]").click

    def scrub_to(value)
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

    def assert_scrubber_value(value)
      scrubber = find("[data-ci='scrubber-range-input']")
      assert_equal value, scrubber.value.to_i
    end
  end
end
