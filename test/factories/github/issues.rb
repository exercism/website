FactoryBot.define do
  factory :github_issue, class: 'Github::Issue' do
    node_id { "MDExOlB1bGxSZXF1ZXN0Mzk0NTa4TYmm" }
    number { 3 }
    title { "Restructure tests" }
    status { :open }
    repo { "exercism/ruby" }
    opened_by_username { "ErikSchierboom" }
    opened_at { Date.new(2021, 0o3, 18) }

    trait :random do
      node_id { SecureRandom.hex }
      number { SecureRandom.random_number(100_000) }
      opened_at { Time.current }
    end
  end
end
