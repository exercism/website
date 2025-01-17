class AddBackgroundSlugToDrawings < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :bootcamp_drawings, :background_slug, :string, null: false, default: "none"
  end
end
