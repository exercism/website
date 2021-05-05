class RemoveLearntConcepts < ActiveRecord::Migration[6.1]
  def change
    drop_table :user_track_learnt_concepts
  end
end
