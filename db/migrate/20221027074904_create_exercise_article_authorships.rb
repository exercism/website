class CreateExerciseArticleAuthorships < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_article_authorships do |t|
      t.belongs_to :exercise_article, foreign_key: true, null: false, index: { name: "index_exercise_article_authorships_on_article_id" }
      t.belongs_to :user, foreign_key: true, null: false

      t.timestamps

      t.index %i[exercise_article_id user_id], unique: true, name: "index_exercise_article_author_article_id_user_id"
    end
  end
end
