FactoryBot.define do
  factory :git_pull_request, class: 'Git::PullRequest' do
    node_id { "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz" }
    number { 2 }
    repo { "exercism/ruby" }
    author_github_username { "iHiD" }
    merged_by_github_username { "ErikSchierboom" }
    data do
      {
        pr_id: node_id,
        pr_number: number,
        repo: repo,
        url: "https://api.github.com/repos/exercism/ruby/pulls/#{number}",
        html_url: "https://github.com/exercism/ruby/pull/#{number}",
        state: "closed",
        action: "closed",
        author: author_github_username,
        labels: [],
        merged: true,
        merged_by: merged_by_github_username,
        reviews: []
      }
    end

    trait :random do
      node_id { SecureRandom.hex }
      number { SecureRandom.random_number(100_000) }

      data do
        {
          pr_id: node_id,
          pr_number: number,
          repo: repo,
          url: "https://api.github.com/repos/exercism/ruby/pulls/#{number}",
          html_url: "https://github.com/exercism/ruby/pull/#{number}",
          state: "closed",
          action: "closed",
          author: author_github_username,
          labels: [],
          merged: true,
          merged_by: merged_by_github_username,
          reviews: []
        }
      end
    end
  end
end
