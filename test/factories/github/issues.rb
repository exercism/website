FactoryBot.define do
  factory :github_issue, class: 'Github::Issue' do
    # node_id { "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz" }
    # number { 2 }
    # title { "The cat sat on the mat" }
    # repo { "exercism/ruby" }

    # data do
    #   {
    #     # TODO: use correct data
    #     node_id: node_id,
    #     number: number,
    #     title: title,
    #     repo: repo,
    #     url: "https://api.github.com/repos/exercism/ruby/pulls/#{number}",
    #     html_url: "https://github.com/exercism/ruby/pull/#{number}",
    #     state: "closed",
    #     action: "closed",
    #     author_username: author_username,
    #     labels: [],
    #     merged: true,
    #     merged_by_username: merged_by_username,
    #     reviews: []
    #   }
    # end
  end
end
