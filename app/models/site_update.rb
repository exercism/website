class SiteUpdate < ApplicationRecord
  include IsParamaterisedSTI
  include Mandate

  self.class_suffix = :update
  self.i18n_category = :site_updates

  scope :published, -> { where('published_at < ?', Time.current) }
  scope :for_track, ->(track) { where(track: track) }
  scope :sorted, -> { order(published_at: :desc) }

  belongs_to :author, optional: true, class_name: "User"
  belongs_to :pull_request, optional: true, class_name: "Github::PullRequest"

  before_validation only: :create do
    self.published_at = Time.current + 3.hours unless published_at
  end

  # TODO: This is very much a stub!
  def editable_by?(user)
    return true unless author

    author.id == user.id
  end

  def pull_request_number=(num)
    # TODO: We should probably check the track is correct
    self.pull_request = ::Github::PullRequest.find_by!(
      repo: "exercism/#{track.repo_url.split('/').last}",
      number: num
    )
  end

  def pull_request_number
    pull_request&.number
  end

  def cacheable_rendering_data
    d = {
      text: text,
      icon_type: icon_type,
      icon_url: icon_url,
      track_icon_url: track&.icon_url,
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

  def expanded?
    [author, title, description].all?(&:present?)
  end

  # Should be overriden in children
  def icon_url
    nil
  end
end
