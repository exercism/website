FactoryBot.define do
  factory :iteration_discussion_post, class: 'Iteration::DiscussionPost' do
    iteration
    discussion { create :solution_mentor_discussion }
    content_markdown { "Some interesting text" }
  end
end
