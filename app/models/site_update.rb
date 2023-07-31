class SiteUpdate < ApplicationRecord
  include IsParamaterisedSTI
  include Mandate

  self.class_suffix = :update
  self.i18n_category = :site_updates

  scope :published, -> { where('published_at < ?', Time.current) }
  scope :for_track, ->(track) { where(track:) }

  # This is optimised. Don't naively rely on user.tracks or select as both are slow
  scope :for_user, ->(user) { where(track_id: user.user_tracks.pluck(:track_id)) }

  # TODO: Add a desc index when we switch to mysql8
  scope :sorted, -> { order(published_at: :desc, id: :desc) }

  belongs_to :author, optional: true, class_name: "User"
  belongs_to :pull_request, optional: true, class_name: "Github::PullRequest"

  has_markdown_field :description

  before_validation only: :create do
    self.published_at = Time.current + 3.hours unless published_at
  end

  # TODO: This is very much a stub!
  def editable_by?(user)
    return true unless author

    author.id == user.id
  end

  def pull_request_number=(num)
    return if num.blank?

    # TODO: We should probably check the track is correct
    self.pull_request = ::Github::PullRequest.find_by!(
      repo: "exercism/#{track.repo_url.split('/').last}",
      number: num
    )
  end

  def pull_request_number = pull_request&.number

  def cacheable_rendering_data
    d = {
      text:,
      icon:,
      published_at: published_at.iso8601
    }

    if track.present?
      d[:track] = {
        title: track.title,
        icon_url: track.icon_url
      }
    end

    if expanded?
      d[:expanded] = {
        author: {
          handle: author.handle,
          avatar_url: author.avatar_url
        },
        title:,
        description_html:
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
    [author, title, description_markdown].all?(&:present?)
  end

  # Should be overriden in children
  def icon_url = nil
end
