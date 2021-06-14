class SiteUpdate < ApplicationRecord
  include IsParamaterisedSTI
  include Mandate

  self.class_suffix = :update
  self.i18n_category = :site_updates

  scope :posted, -> { where('posted_at < ?', Time.current) }

  before_create do
    self.published_at = Time.current + 3.hours unless published_at
  end

  def cacheable_rendering_data
    {
      text: text,
      icon_url: icon_url
    }
  end
end
