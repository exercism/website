class AddUuidToMentorTestimonials < ActiveRecord::Migration[6.1]
  def change
    add_column :mentor_testimonials, :uuid, :string, null: true
    Mentor::Testimonial.find_each {|t|t.update(uuid: SecureRandom.uuid)}
    change_column_null :mentor_testimonials, :uuid, false
  end
end
