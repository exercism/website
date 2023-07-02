FactoryBot.define do
  factory :partner do
    slug { "partner_#{SecureRandom.hex(4)}" }
    name { slug.to_s.titleize }
    support_explanation { "Paid a tons of money" }
    description_markdown { "# Hey" }
  end
end
