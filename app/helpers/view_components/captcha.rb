module ViewComponents
  class Captcha < ViewComponent
    def initialize(endpoint = HCaptcha.endpoint, site_key = HCaptcha.site_key)
      @endpoint = endpoint
      @site_key = site_key
    end

    def to_s
      tag.div(class: "h-captcha", data: { sitekey: site_key }) do
        tag.script(nil, async: true, defer: "defer", src: "#{endpoint}/1/api.js")
      end
    end

    private
    attr_reader :endpoint, :site_key
  end
end
