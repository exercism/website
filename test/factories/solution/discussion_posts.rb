FactoryBot.define do
  factory :solution_discussion_post, class: 'Solution::DiscussionPost' do
    iteration
    discussion { create :solution_mentor_discussion }
    content_markdown { "Some interesting text" }
  end
end
