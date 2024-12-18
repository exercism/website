require 'rest-client'
require 'json'

class User
  module Bootcamp
    class SubscribeToOnboardingEmails
      include Mandate

      initialize_with :bootcamp_data

      def call
        return unless bootcamp_data.enrolled?
        return User::Bootcamp::SubscribeToOnboardingEmails.(duplicate) if duplicate

        new_sub = add_subscriber!
        add_to_form! if new_sub
      end

      def add_subscriber!
        resp = RestClient.post(
          'https://api.kit.com/v4/subscribers',
          {
            "email_address": bootcamp_data.email,
            "fields": {
              "enrolled_at": bootcamp_data.enrolled_at,
              "has_paid": bootcamp_data.paid?,
              "package": bootcamp_data.package,
              "country_name": bootcamp_data.country_name,
              "payment_url": bootcamp_data.payment_url,
              "price": bootcamp_data.price,
              "has_discount": bootcamp_data.has_discount?,
              "discount_percentage": bootcamp_data.discount_percentage
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
          "https://api.kit.com/v4/forms/#{BOOTCAMP_FORM_ID}/subscribers",
          {
            "email_address": bootcamp_data.email
          }, HEADERS
        )
      end

      def duplicate
        return if bootcamp_data.paid?

        User::BootcampData.
          where(email: bootcamp_data.email).
          where.not(id: bootcamp_data.id).
          paid.
          first
      end

      HEADERS = {
        'Accept': 'application/json',
        'X-Kit-Api-Key': Exercism.secrets.key_api4_key
      }.freeze
      BOOTCAMP_FORM_ID = "7317281".freeze
    end
  end
end
