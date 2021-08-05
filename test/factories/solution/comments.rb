FactoryBot.define do
  factory :solution_comment, class: 'Solution::Comment' do
    solution { create :practice_solution }
    author { create :user }
    content_markdown { "Hello, there!" }
  end
end
