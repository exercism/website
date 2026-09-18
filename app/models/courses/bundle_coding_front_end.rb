class Courses::BundleCodingFrontEnd < Courses::Course
  include Singleton

  def slug = "bundle-coding-front-end"

  def enable_for_user!(user)
    Courses::Course.course_for_slug("coding-fundamentals").enable_for_user!(user)
    Courses::Course.course_for_slug("front-end-fundamentals").enable_for_user!(user)

    # Put the user at the start.
    user.bootcamp_data.update!(active_part: 1)
  end
end
