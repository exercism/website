# Inlines a user's avatar as a data URI, for the image generator.
#
# The generator runs in a Lambda whose only route to the internet is a NAT
# gateway. Handing it an https://assets.exercism.org/... URL meant every render
# fetched the avatar back out through that NAT, through Cloudflare, through
# CloudFront and into our own ALB - a full round trip out of and back into the
# same AWS account, for a file we can read straight from S3.
#
# Returns nil rather than raising if there's nothing to inline (or if anything
# goes wrong), so callers can fall back to avatar_url and let the generator
# fetch it the old way. A slow avatar must never fail a render.
class User::AvatarDataUri
  include Mandate

  initialize_with :user

  def call
    return nil unless user.avatar.attached?

    # Always the variant, never the original. Avatars are drawn at ~40-100px
    # and the originals are whatever was uploaded - there is a 352KB BMP in
    # there - so this is both a bandwidth and a correctness fix: satori cannot
    # decode BMP and errors out *after* downloading the whole thing.
    variant = user.avatar.variant(:thumb).processed

    "data:#{variant.content_type};base64,#{Base64.strict_encode64(variant.download)}"
  rescue StandardError => e
    Sentry.capture_exception(e)
    nil
  end
end
