slug = "codecrafters"
light_image_slug = slug
dark_image_slug = slug

partner_attributes = {
  name: 'Code Crafters',
  headline: "Advanced programming challenges",

  website_url: 'https://https://codecrafters.io',
  description_markdown: <<~MARKDOWN

    Exercism does a fantastic job of teaching you language fundamentals. 
    If teaches you how to think in a language, how to master its idioms and idiosyncrasies.

    But what about when you want to put those new skills into use in a **real project?**

    That's where Code Crafters comes in!

    Code Crafters offer **real-world proficiency projects** designed for experienced engineers. 
    They're designed to develop software craftsmanship by recreating popular devtools from scratch.
    
    We've partnered up with Code Crafters to give you a chunky 40% discount.
    Plus, every time someone subscribes, Code Crafters make a generous donation to Exercism.
    So not only are you getting some great projects to practice with, but you're supporting Exercism at the same time!
  MARKDOWN
} 

perk_attributes = {
  preview_text: "Ready to put your new-found language skills into practice? We recommend Code Crafters' real-world proficiency projects.",
  general_url: "https://app.codecrafters.io/join?via=Exercism",
  general_offer_summary_markdown: "Try CodeCrafters for free (no card required) and if you choose to upgrade, get 40% off!",
  general_button_text: "Claim 40% discount",
  general_offer_details: "Sign up for free then have the discount applied if you choose to upgrade!",
  general_voucher_code: nil,
  insiders_url: "https://app.codecrafters.io/join?via=Exercism",
  insiders_offer_summary_markdown: "Try CodeCrafters for free (no card required) and if you choose to upgrade, get 50% off!",
  insiders_button_text: "Claim 50% discount",
  insiders_offer_details: "Sign up for free, then email hello@codecrafters.io to get this exclusive Insiders discount (so exclusive their system can't copy with automating it!)",
  insiders_voucher_code: nil
}

advert_attributes = {
  url: "https://app.codecrafters.io/join?via=Exercism",
  markdown: "Ready to put your newfound language skills into use? **Get 40% off** CodeCrafter's real-world proficiency projects!",
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

advert = partner.adverts.first
if advert
  advert.update!(advert_attributes)
else
  partner.adverts.create!(advert_attributes.merge(status: :pending))
end
