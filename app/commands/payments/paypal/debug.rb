class Payments::Paypal::Debug
  include Mandate

  initialize_with :message

  def call
    return unless Rails.env.production?

    IO.write("/mnt/efs/repos/debug/paypal.txt", "#{message}\n", mode: 'a')
  rescue StandardError
    # We don't want debug logging errors to crash anything
  end
end
