class UpdateConceptBlurbColumnLength < ActiveRecord::Migration[6.1]
  def change
    change_column :track_concepts, :blurb, :string, limit: 350
  end
end
