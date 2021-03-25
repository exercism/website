FactoryBot.define do
  factory :mentor_discussion_post, class: 'Mentor::DiscussionPost' do
    iteration
    discussion { create :mentor_discussion }
    author { discussion.mentor }
    content_markdown { "Some interesting text" }
  end
end
