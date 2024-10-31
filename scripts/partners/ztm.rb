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
  preview_text: "If you like Exercism, you'll like ZTM's courses built by programmers (not influencers), for programmers. ZTM helps you get a better job and earn more with one trick: quality, not gimmicks.",
  general_url: "https://links.zerotomastery.io/exercism-perk",
  general_offer_summary_markdown: "Get 20% off your first team Kaido Challenge with your Exercism account.",
  general_offer_summary_html: "<p>Get 20% off your first team Kaido Challenge with your Exercism account.</p>\n",
  general_button_text: "Claim 20% discount",
  general_offer_details: "Get 20% off your first Kaido Challenge with your Exercism account.",
  general_voucher_code: "EXERCISM20",
  insiders_url: nil,
  insiders_offer_summary_markdown: nil,
  insiders_offer_summary_html: nil,
  insiders_button_text: nil,
  insiders_offer_details: nil,
  insiders_voucher_code: nil,
}

partner = Partner.find_or_create_by!(slug: slug) { |p| p.attributes = partner_attributes }
partner.update!(partner_attributes)
partner.light_logo.attach(io: File.open(Rails.root.join("app/images/partners/#{light_image_slug}.svg")), filename: "#{slug}-light.svg")
partner.dark_logo.attach(io: File.open(Rails.root.join("app/images/partners/#{dark_image_slug}.svg")), filename: "#{slug}-dark.svg")

perk = partner.perks.active.first
if perk
  perk.update!(perk_attributes)
else
  partner.perks.create!(perk_attributes.merge(status: :active))
end
