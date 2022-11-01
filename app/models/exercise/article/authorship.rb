class Exercise::Article::Authorship < ApplicationRecord
  belongs_to :article,
    class_name: "Exercise::Article",
    foreign_key: :exercise_article_id,
    inverse_of: :authorships

  belongs_to :author,
    class_name: "User",
    foreign_key: :user_id,
    inverse_of: :article_authorships
end
