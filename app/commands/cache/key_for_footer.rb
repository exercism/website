class Cache::KeyForFooter
  include Mandate

  initialize_with :current_user

  def call
    parts = digests
    parts << Date.current.year
    parts << ::Track.num_active
    parts << user_part
    parts << stripe_version
    parts << I18n.available_locales.count
    parts << "3" # Basic expiry key

    parts.join(':')
  end

  private
  def user_part
    return 0 unless current_user

    current_user.captcha_required? ? 2 : 1
  end

  def stripe_version = 3

  def digests
    %w[external shared].map do |file|
      Digest::SHA1.hexdigest(File.read(Rails.root.join('app', 'views', 'components', 'footer', "#{file}.html.haml")))
    end
  end
end
