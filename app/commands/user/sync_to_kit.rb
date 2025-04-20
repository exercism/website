require 'rest-client'
require 'json'

class User
  class SyncToKit
    include Mandate

    initialize_with :user

    def call
      return unless course_enrollments.any?

      new_sub = add_subscriber!
      add_to_form! if new_sub
    end

    private
    delegate :course_enrollments, to: :user

    memoize
    def email
      course_enrollments.paid.last&.email || course_enrollments.last.email || user.email
    end

    memoize
    def first_enrolled_on
      course_enrollments.order(:created_at).first.created_at.to_date.to_s.delete('-')
    end

    memoize
    def owns_coding_fundamentals?
      course_enrollments.paid.any? { |ce| ce.course_slug == "coding-fundamentals" || ce.course_slug == "bundle-coding-front-end" }
    end

    memoize
    def owns_front_end_fundamentals?
      course_enrollments.paid.any? { |ce| ce.course_slug == "front-end-fundamentals" || ce.course_slug == "bundle-coding-front-end" }
    end

    memoize
    def owns_something?
      owns_coding_fundamentals? || owns_front_end_fundamentals?
    end

    def add_subscriber!
      resp = RestClient.post(
        'https://api.kit.com/v4/subscribers',
        {
          "email_address": email,
          "fields": {
            "user_id": user.id,
            "owns_something": owns_something?,
            "owns_coding_fundamentals": owns_coding_fundamentals?,
            "owns_front_end_fundamentals": owns_front_end_fundamentals?,
            "first_enrolled_on": first_enrolled_on
          }
        },
        HEADERS
      )

      # If we have a 201 it's a new subscriber.
      # If not, then we've just upserted it.
      resp.code == 201
    end

    def add_to_form!
      RestClient.post(
        "https://api.kit.com/v4/forms/#{SUBSCRIBE_FORM_ID}/subscribers",
        {
          "email_address": email
        }, HEADERS
      )
    end

    HEADERS = {
      'Accept': 'application/json',
      'X-Kit-Api-Key': Exercism.secrets.key_api4_key
    }.freeze
    SUBSCRIBE_FORM_ID = "7391354".freeze
  end
end
