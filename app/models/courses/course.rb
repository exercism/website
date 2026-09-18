class Courses::Course
  def self.course_for_slug(slug)
    courses = [
      Courses::CodingFundamentals.instance,
      Courses::FrontEndFundamentals.instance,
      Courses::BundleCodingFrontEnd.instance
    ].index_by(&:slug).freeze
    courses[slug]
  end
end
