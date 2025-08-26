class Localization::DashboardController < ApplicationController
  def show
    @locale_counts = Localization::Translation.group(:locale, :status).count.
      each_with_object({}) do |((locale, status), count), h|
        h[locale.to_sym] ||= {}
        h[locale.to_sym][status.to_sym] = count
      end
  end
end
