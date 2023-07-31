class AddUuidToExerciseRepresentations < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_representations, :uuid, :string, null: true, if_not_exists: true
    add_index :exercise_representations, :uuid, unique: true, if_not_exists: true

    # TODO: consider if we can run this in production
    unless Rails.env.production?
      ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
        Exercise::Representation.find_each do |representation|
          Exercise::Representation
            .where(id: representation.id)
            .update_all('`uuid` = UUID()')
        end
      end
    end

    # change_column_null :exercise_representations, :uuid, false
  end
end
