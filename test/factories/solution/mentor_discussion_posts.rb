FactoryBot.define do
  factory :solution_mentor_discussion_post, class: 'Solution::MentorDiscussionPost' do
    iteration
    discussion { create :solution_mentor_discussion }
    author { discussion.mentor }
    content_markdown { "Some interesting text" }
  end
end
