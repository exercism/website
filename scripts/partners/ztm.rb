slug = "ztm"
light_image_slug = slug
dark_image_slug = slug

partner_attributes = {
  name: 'Zero To Mastery',
  headline: "Upgrade Your Career & Earnings As A Developer",

  website_url: 'https://zerotomastery.io/',
  description_markdown: <<~MARKDOWN
    Feeling stuck in your current role? We’ve all been there. If you want to level up, get promoted, and boost your earnings, then Zero To Mastery is for you.

    You’ll join 1,000,000+ developers learning the most in-demand skills from industry experts (not influencers) & getting hired at companies like Apple, Google, Amazon, Tesla & Shopify.
 
    ## What makes ZTM a great place to learn tech skills and level up your career?

    ### Most in-demand skills. Always up-to-date.
    Get ahead with 24/7 access to step-by-step video lessons covering the latest skills in programming, A.I., machine learning, UX/UI design, devops, cybersecurity, data analytics, web3, and more. Most importantly, our courses are always up-to-date (unlike most learning platforms out there).

    ### Build real-world projects.
    Gain the skills, confidence, and portfolio you need to stand out to employers by building and deploying projects that simulate real-world job tasks.

    ### Get hired (or promoted) in record time.
    Your time is valuable. That's why our step-by-step Career Paths give you a clear roadmap to go from any background to getting hired or getting that raise as fast as possible.

    ### Community support.
    Learning and navigating your career alone is hard. At some point, you’ll get stuck or have questions or need advice. When that happens our community of 400,000+ students, alumni, mentors, and expert instructors will be there to help answer any question. You’ll also get to attend our monthly live events including career advice sessions with senior developers.
  MARKDOWN
} 

perk_attributes = {
  preview_text: "ZTM's courses are built by programmers, not influencers. ZTM helps you get a better job and earn more with one trick: quality, not gimmicks.",
  general_url: "https://zerotomastery.io",
  general_offer_summary_markdown: "Get 20% off a ZTM membership with your Exercism membership.",
  general_button_text: "Claim 20% discount",
  general_offer_details: "Copy the discount code below, then use it at checkout to get 20% off your ZTM membership.",
  general_voucher_code: "EXERCISM20",
  insiders_url: "https://zerotomastery.io",
  insiders_offer_summary_markdown: "Get 25% off a ZTM membership with your Exercism Insiders membership",
  insiders_button_text: "Claim 25% discount",
  insiders_offer_details: "Copy the discount code below, then use it at checkout to get 25% off your ZTM membership.",
  insiders_voucher_code: "EXERCISM25",
}

js_advert_attributes = {
  track_slugs: ["javascript"],
  url: "https://links.zerotomastery.io/exercism-ajs",
  markdown: "Want to master advanced JavaScript? **Get 20% off** a ZTM annual membership!",
}

py_advert_attributes = {
  track_slugs: ["python"],
  url: "https://links.zerotomastery.io/exercism-ml",
  markdown: "Want to boost your data science skills? **Get 20% off** a ZTM annual membership!",
}

partner = Partner.find_or_create_by!(slug: slug) { |p| p.attributes = partner_attributes }
partner.update!(partner_attributes)
partner.light_logo.attach(io: File.open(Rails.root.join("app/images/partners/#{light_image_slug}-light.svg")), filename: "#{slug}-light.svg")
partner.dark_logo.attach(io: File.open(Rails.root.join("app/images/partners/#{dark_image_slug}-dark.svg")), filename: "#{slug}-dark.svg")

perk = partner.perks.first
if perk
  perk.update!(perk_attributes)
else
  partner.perks.create!(perk_attributes.merge(status: :pending))
end

js_advert = partner.adverts.select{|a| a.track_slugs.include?("javascript")}.first
if js_advert
  js_advert.update!(js_advert_attributes)
else
  partner.adverts.create!(js_advert_attributes.merge(status: :pending))
end

py_advert = partner.adverts.select{|a| a.track_slugs.include?("python")}.first
if py_advert
  py_advert.update!(py_advert_attributes)
else
  partner.adverts.create!(py_advert_attributes.merge(status: :pending))
end
