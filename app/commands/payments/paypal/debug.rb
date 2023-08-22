class Payments::Paypal::Debug
  include Mandate

  initialize_with :message

  def call
    return unless Rails.env.production?

    IO.write("/mnt/efs/repos/debug/paypal.txt", "#{timestamp} #{message}\n\n", mode: 'a')
  rescue StandardError
    # We don't want debug logging errors to crash anything
  end

  private
  def timestamp = Time.current.strftime('%Y-%m-%d %H:%M:%S')
end
