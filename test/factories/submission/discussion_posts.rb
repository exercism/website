FactoryBot.define do
  factory :submission_discussion_post, class: 'Submission::DiscussionPost' do
    submission
    source { create :solution_mentor_discussion }
    user { source.mentor }
    content_markdown { "Some interesting text" }
  end
end
