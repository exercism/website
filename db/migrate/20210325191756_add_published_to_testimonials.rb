class AddPublishedToTestimonials < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_testimonials, :published, :boolean, null: false, default: true
    add_column :mentor_testimonials, :deleted_at, :datetime, null: true
  end
end
