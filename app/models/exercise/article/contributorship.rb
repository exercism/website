class Exercise::Article::Contributorship < ApplicationRecord
  belongs_to :article,
    class_name: "Exercise::Article",
    foreign_key: :exercise_article_id,
    inverse_of: :contributorships

  belongs_to :contributor,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :article_contributorships
end
