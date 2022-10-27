FactoryBot.define do
  factory :exercise_article_contributorship, class: 'Exercise::Article::Contributorship' do
    article { create :exercise_article }
    contributor { create :user }
  end
end
