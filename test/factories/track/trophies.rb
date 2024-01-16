FactoryBot.define do
  factory :trophy, class: 'Track::Trophies::MentoredTrophy' do
  end

  %i[
    completed_all_exercises completed_fifty_percent_of_exercises
    completed_twenty_exercises mentored iterated_twenty_exercises
    read_fifty_community_solutions completed_five_hard_exercises
    completed_learning_mode functional
  ].each do |type|
    factory "#{type}_trophy", class: "Track::Trophies::#{type.to_s.camelize}Trophy" do
    end
  end
end
