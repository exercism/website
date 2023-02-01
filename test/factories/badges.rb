FactoryBot.define do
  factory :badge, class: 'Badges::RookieBadge' do
  end

  # rubocop:disable Naming/VariableNumber
  %i[
    member rookie supporter contributor
    anybody_there growth_mindset v1 v2
    new_years_resolution die_unendliche_geschichte
    all_your_base whatever lackadaisical
    mentor researcher v3_pioneer tooling_pioneer
    moss begetter bard architect troubleshooter
    completer conceptual supermentor
    participant_in_12_in_23 functional_february
  ].each do |type|
    factory "#{type}_badge", class: "Badges::#{type.to_s.camelize}Badge" do
    end
  end
  # rubocop:enable Naming/VariableNumber
end
