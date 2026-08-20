require 'open-uri'

# Inlines a user's avatar as a PNG data URI, for the image generator.
#
# The generator runs in a Lambda whose only route to the internet is a NAT
# gateway. Handing it a URL - ours or a third party's - meant every render
# fetched the avatar out through that NAT. The NAT is billed as a standing
# hourly charge, so the target is *zero* egress from that subnet, not less of
# it: every render has to be able to draw its avatar from inlined bytes.
#
# There are two sources:
#
#   1. An ActiveStorage attachment - read straight from S3 and inlined.
#   2. An external avatar_url (typically avatars.githubusercontent.com) for
#      users who never uploaded one. We fetch it here, in Rails, because Rails
#      runs in public subnets and egresses via the internet gateway. This
#      mirrors what AvatarsController already does for the public avatar path.
#
# The external fetch happens on every call, deliberately: nothing is cached, so
# a user who changes their avatar sees it change everywhere immediately.
#
# Returns nil rather than raising if there's nothing to inline (or if anything
# goes wrong), so callers can fall back to avatar_url. A slow or dead
# third-party avatar host must never fail a render.
class User::AvatarDataUri
  include Mandate

  initialize_with :user

  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 5

  def call
    return attachment_data_uri if user.avatar.attached?
    return nil if external_avatar_url.blank?

    external_data_uri
  rescue StandardError => e
    Sentry.capture_exception(e)
    nil
  end

  private
  # Always the variant, never the original. Avatars are drawn at ~32-100px and
  # the originals are whatever was uploaded - there is a 352KB BMP in there -
  # so this is both a bandwidth and a correctness fix: satori cannot decode BMP
  # and errors out *after* downloading the whole thing.
  def attachment_data_uri
    variant = user.avatar.variant(:thumb).processed

    data_uri(variant.download)
  end

  def external_data_uri = data_uri(thumbnailed(download_external_avatar))

  def download_external_avatar
    uri = URI.parse(external_avatar_url)
    raise ArgumentError, "Unsupported avatar_url scheme" unless uri.is_a?(URI::HTTP)

    uri.open(open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT, &:read)
  end

  # The same treatment the :thumb variant gets (see User's has_one_attached
  # block). convert: :png is load-bearing - satori sniffs magic bytes and
  # ignores the data URI's MIME label, and it cannot decode BMP or SVG.
  def thumbnailed(data)
    source = Tempfile.new(%w[avatar-source], binmode: true)
    source.write(data)
    source.flush

    thumbnail = ImageProcessing::Vips.
      source(source.path).
      convert("png").
      resize_to_fill(200, 200).()

    File.binread(thumbnail.path)
  ensure
    source&.close!
    thumbnail&.close!
  end

  def data_uri(data) = "data:image/png;base64,#{Base64.strict_encode64(data)}"

  # User#avatar_url is overridden to point at our own avatars host, so the
  # external URL has to come off the attributes directly - same as
  # AvatarsController does.
  def external_avatar_url = user.attributes['avatar_url']
end
