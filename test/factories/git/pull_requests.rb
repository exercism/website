FactoryBot.define do
  factory :git_pull_request, class: 'Git::PullRequest' do
    node_id { "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz" }
    number { 2 }
    repo { "exercism/ruby" }
    author_github_username { "iHiD" }
    event do
      {
        url: "https://api.github.com/repos/exercism/ruby/pulls/2",
        repo: "exercism/ruby",
        pr_id: "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz",
        pr_number: 2,
        state: "closed",
        action: "closed",
        author: "iHiD",
        labels: [],
        merged: true,
        reviews: [{ user: { login: "ErikSchierboom" } }],
        html_url: "https://github.com/exercism/ruby/pull/2"
      }
    end
  end
end
