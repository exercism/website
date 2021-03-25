FactoryBot.define do
  factory :github_pull_request, class: 'Github::PullRequest' do
    node_id { "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz" }
    number { 2 }
    title { "The cat sat on the mat" }
    repo { "exercism/ruby" }
    author_username { "iHiD" }
    merged_by_username { "ErikSchierboom" }
    data do
      {
        node_id: node_id,
        number: number,
        title: title,
        repo: repo,
        url: "https://api.github.com/repos/exercism/ruby/pulls/#{number}",
        html_url: "https://github.com/exercism/ruby/pull/#{number}",
        state: "closed",
        action: "closed",
        author_username: author_username,
        labels: [],
        merged: true,
        merged_by_username: merged_by_username,
        reviews: []
      }
    end

    trait :random do
      node_id { SecureRandom.hex }
      number { SecureRandom.random_number(100_000) }
    end
  end
end
