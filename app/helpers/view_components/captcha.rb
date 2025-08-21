module ViewComponents
  class Captcha < ViewComponent
    def to_s
      tag.div do
        tag.div(
          class: "cf-turnstile",
          data: {
            sitekey: Exercism.secrets.turnstile_site_key,
            callback: "turnstileEnableSubmitButton",
            size: "flexible",
            theme: "light"
          }
        ) +
          tag.script(src: "https://challenges.cloudflare.com/turnstile/v0/api.js", defer: true) +
          tag.script(type: "text/javascript") do
            <<~JS.html_safe
              /* Get the .cf-turnstile element, find its parent form, and enable the submit button */
              window.turnstileEnableSubmitButton = () => {
                const turnstileElement = document.querySelector('.cf-turnstile');
                const form = turnstileElement.closest('form');
                const submitButton = form.querySelector('button[type="submit"]');
                submitButton.disabled = false;
              }
            JS
          end
      end
    end
  end
end
