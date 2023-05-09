class Mentor::Testimonial::Create
  include Mandate

  initialize_with :discussion, :testimonial

  def call
    Mentor::Testimonial.create!(
      mentor: discussion.mentor,
      student: discussion.student,
      discussion:,
      content: testimonial
    )
    User::ResetCache.defer(discussion.mentor)
  end
end
