class SiteUpdate < ApplicationRecord
  include IsParamaterisedSTI
  include Mandate

  self.class_suffix = :update
  self.i18n_category = :site_updates

  scope :published, -> { where('published_at < ?', Time.current) }

  before_validation only: :create do
    self.published_at = Time.current + 3.hours unless published_at
  end

  def cacheable_rendering_data
    d = {
      text: text,
      icon_url: icon_url,
      published_at: published_at.iso8601
    }

    if expanded?
      d[:expanded] = {
        author_handle: author.handle,
        author_avatar_url: author.avatar_url,
        title: title,
        description: description
      }
    end

    if pull_request
      d[:pull_request] = {
        title: pull_request.title,
        number: pull_request.number,
        url: "https://github.com/#{pull_request.repo}/pull/#{pull_request.number}",
        merged_by: pull_request.merged_by_username,
        merged_at: pull_request.updated_at.iso8601 # TODO: Use merged_at?
      }
    end

    d
  end

  private
  def expanded?
    [author, title, description].all?(&:present?)
  end
end
