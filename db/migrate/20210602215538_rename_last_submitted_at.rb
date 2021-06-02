class RenameLastSubmittedAt < ActiveRecord::Migration[6.1]
  def change
    rename_column :solutions, :last_submitted_at, :last_iterated_at
  end
end
