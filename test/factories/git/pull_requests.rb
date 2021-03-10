FactoryBot.define do
  factory :git_pull_request, class: 'Git::PullRequest' do
    node_id { "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz" }
    number { 2 }
    repo { "exercism/ruby" }
    author_github_username { "iHiD" }
    merged_by_github_username { "ErikSchierboom" }
    data do
      {
        pr_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
        pr_number: 2,
        repo: "exercism/ruby",
        url: "https://api.github.com/repos/exercism/ruby/pulls/2",
        html_url: "https://github.com/exercism/ruby/pull/2",
        state: "closed",
        action: "closed",
        author: "iHiD",
        labels: [],
        merged: true,
        merged_by: "ErikSchierboom",
        reviews: []
      }
    end

    trait :random do
      after(:build) do |pr|
        random_node_id = SecureRandom.hex
        random_number = SecureRandom.random_number(100_000)
        pr.update!(
          node_id: random_node_id,
          number: random_number,
          data: pr.data.tap do |d|
            d[:pr_id] = random_node_id
            d[:pr_number] = random_number
          end
        )
      end
    end
  end
end
