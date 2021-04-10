class Mentoring::TestimonialsController < ApplicationController
  before_action :ensure_mentor!

  def index
    # TODO: - Paginate
    @testimonials = [
      current_user.mentor_testimonials.first,
      *(current_user.mentor_testimonials.to_a * 10).tap { |ts| ts.each { |t| t.revealed = true } }
    ]
  end
end
