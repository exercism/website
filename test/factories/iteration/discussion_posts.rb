FactoryBot.define do
  factory :iteration_discussion_post, class: 'Iteration::DiscussionPost' do
    iteration
    source { create :solution_mentor_discussion }
    user { source.mentor }
    content_markdown { "Some interesting text" }
  end
end
