FactoryBot.define do
  factory :badge, class: 'Badges::RookieBadge' do
  end

  %i[
    member rookie supporter contributor
    anybody_there growth_mindset
    mentor
  ].each do |type|
    factory "#{type}_badge", class: "Badges::#{type.to_s.camelize}Badge" do
    end
  end
end
