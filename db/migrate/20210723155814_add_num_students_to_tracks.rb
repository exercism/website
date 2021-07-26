class AddNumStudentsToTracks < ActiveRecord::Migration[6.1]
  def change
    add_column :tracks, :num_students, :integer, null: false, default: 0
  end
end
