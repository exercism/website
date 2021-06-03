FactoryBot.define do
  factory :github_task, class: 'Github::Task' do
    track do
      Track.find_by(slug: :ruby) || build(:track, slug: 'ruby')
    end

    title { 'Sync anagram exercise' }
    repo { 'exercism/ruby' }
    issue_url { 'https://github.com/exercism/ruby/issues/122' }
    opened_by_username { 'ErikSchierboom' }
    opened_at { Date.new(2021, 3, 18) }
    action { :sync }
    knowledge { :advanced }
    area { :analyzer }
    size { :s }
    type { :coding }

    trait :random do
      title { "Sync #{SecureRandom.hex(8)} exercise" }
      issue_url { "https://github.com/exercism/#{track.slug}/issues/#{SecureRandom.random_number(100_000)}" }
      opened_at { Time.current }
    end
  end
end
