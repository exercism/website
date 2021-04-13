class AddRevealedToTestimonials < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_testimonials, :revealed, :boolean, null: false, default: false
    Mentor::Testimonial.update_all(revealed: true)
  end
end
