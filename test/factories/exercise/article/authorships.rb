FactoryBot.define do
  factory :exercise_article_authorship, class: 'Exercise::Article::Authorship' do
    article { create :exercise_article }
    author { create :user }
  end
end
