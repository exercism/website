FactoryBot.define do
  factory :badge, class: 'Badges::RookieBadge' do
  end

  %i[ # rubocop:disable Naming/VariableNumber
      member rookie supporter contributor
      anybody_there growth_mindset v1].each do |type| # rubocop:disable Naming/VariableNumber
    factory "#{type}_badge", class: "Badges::#{type.to_s.camelize}Badge" do
    end
  end
end
