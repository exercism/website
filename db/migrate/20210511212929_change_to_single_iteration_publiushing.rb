class ChangeToSingleIterationPubliushing < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :solutions, :published_iteration, foreign_key: {to_table: :iterations}, optional: true
    remove_column :iterations, :published
  end
end
