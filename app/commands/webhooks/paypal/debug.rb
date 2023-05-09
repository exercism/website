class Webhooks::Paypal::Debug
  include Mandate

  initialize_with :message

  def call
    return unless Rails.env.production?

    IO.write("/mnt/efs/repos/debug/paypal.txt", message, mode: 'a')
  end
end
