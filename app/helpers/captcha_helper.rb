module CaptchaHelper
  def captcha_tags
    tag.div(class: "h-captcha", data: { sitekey: HCaptcha.site_key }) do
      tag.script(nil, async: true, defer: "defer", src: "#{HCaptcha.endpoint}/1/api.js")
    end
  end
end
