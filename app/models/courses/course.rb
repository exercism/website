class Courses::Course
  def self.course_for_slug(slug)
    courses = [
      Courses::CodingFundamentals.instance,
      Courses::FrontEndFundamentals.instance,
      Courses::BundleCodingFrontEnd.instance
    ].index_by(&:slug).freeze
    courses[slug]
  end

  def url = Exercism::Routes.course_url(slug)

  def send_welcome_email!(enrollment)
    mail_slug = "#{template_slug}_enrolled"
    if enrollment.user
      User::SendEmail.(enrollment) do
        CoursesMailer.with(enrollment:).send(mail_slug).deliver_later
      end
    else
      return unless enrollment.email_pending?

      CoursesMailer.with(enrollment:).send(mail_slug).deliver_later
      enrollment.email_sent!
    end
  end

  def pricing_data_for_country(country_code_2)
    return unless country_code_2

    raw = DATA[country_code_2]
    return unless raw

    # Transpose to a hash
    [
      %i[country_name hello bundle_price course_price bundle_payment_url course_payment_url bundle_price_id course_price_id],
      raw
    ].transpose.to_h.tap do |data|
      data[:course_price] = data[:course_price].to_f
      data[:bundle_price] = data[:bundle_price].to_f
      data[:discount_percentage] = ((full_price - data[:course_price]) / full_price * 100).round
    end
  end

  DATA = JSON.parse(File.read(Rails.root / 'config' / 'bootcamp.json')).freeze
end
