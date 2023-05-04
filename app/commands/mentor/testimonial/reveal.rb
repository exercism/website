class Mentor::Testimonial::Reveal
  include Mandate

  initialize_with :testimonial

  def call
    return if testimonial.revealed?

    testimonial.update!(revealed: true)
    User::ResetCache.(testimonial.mentor)
  end
end
