FactoryBot.define do
  factory :supporting_organisation do
    slug { "supporting_org_#{SecureRandom.hex(4)}" }
    name { slug.to_s.titleize }
    support_explanation { "Paid a tons of money" }
    description_markdown { "# Hey" }
    insiders_offer_description { "Everything is free" }
  end
end
