class AddTitleToDrawings < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :bootcamp_drawings, :title, :string, null: true
  
    Bootcamp::Drawing.all.each do |drawing|
      drawing.update!(title: "Drawing #{drawing.id}")
    end

    change_column_null :bootcamp_drawings, :title, false
  end
end
