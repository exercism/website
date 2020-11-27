require "hcaptcha"

HCaptcha.configure do |hc|
  hc.endpoint = "https://hcaptcha.com"
  hc.secret = "CHANGEME"
  hc.site_key = "CHANGEME"
end
