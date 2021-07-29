FactoryBot.define do
  factory :badge, class: 'Badges::RookieBadge' do
  end

  %i[member rookie supporter].each do |type|
    factory "#{type}_badge", class: "Badges::#{type.to_s.camelize}Badge" do
    end
  end

  factory :anybody_there_badge, class: 'Badges::AnybodyThereBadge' do
  end

  factory :growth_mindset_badge, class: 'Badges::GrowthMindsetBadge' do
  end
end
