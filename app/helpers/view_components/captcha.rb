module ViewComponents
  class Captcha < ViewComponent
    def to_s
      tag.div(class: "h-captcha", data: { sitekey: site_key }) do
        tag.script(nil, async: true, defer: "defer", src: "#{endpoint}/1/api.js")
      end
    end

    private
    def endpoint = Exercism.config.hcaptcha_endpoint
    def site_key = Exercism.secrets.hcaptcha_site_key
  end
end
