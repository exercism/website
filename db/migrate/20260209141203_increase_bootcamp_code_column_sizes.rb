class IncreaseBootcampCodeColumnSizes < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    change_column :bootcamp_submissions, :code, :text, size: :medium
    change_column :bootcamp_solutions, :code, :text, size: :medium
    change_column :bootcamp_drawings, :code, :text, size: :medium
  end
end
