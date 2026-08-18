class CreateSolutionAssistantConversations < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :solution_assistant_conversations do |t|
      t.belongs_to :solution, foreign_key: true, null: false, index: { unique: true }
      t.belongs_to :user, foreign_key: true, null: false
      t.json :messages

      t.timestamps
    end
  end
end
