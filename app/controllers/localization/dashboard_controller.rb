class Localization::DashboardController < ApplicationController
  before_action :ensure_translator_locale
  def show
    @locale_counts = Localization::Translation.group(:locale, :status).count.
      each_with_object({}) do |((locale, status), count), h|
        h[locale.to_sym] ||= {}
        h[locale.to_sym][status.to_sym] = count
      end
  end

  private
  def ensure_translator_locale
    return if current_user&.translator_locales.present?

    redirect_to new_localization_translator_path
  end
end
