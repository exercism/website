FactoryBot.define do
  factory :user_github_solution_syncer, class: 'User::GithubSolutionSyncer' do
    user
    repo_full_name { "example/repo" }
    installation_id { 123_456_789 }
  end
end
