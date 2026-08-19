# Everything the image generator needs to draw a solution's share image, in one
# request.
#
# The generator used to get this by loading the HTML page in headless Chrome,
# waiting for React to mount, and letting it fetch the files over XHR. Serving
# the data directly means it can render without a browser at all.
class SerializeSolutionImage
  include Mandate

  initialize_with :solution

  def call
    {
      code: {
        language: solution.track.highlightjs_language,
        indent_size: solution.track.indent_size,
        files:
      },
      footer: {
        handle: solution.user.handle,
        # Both, deliberately. avatar_data saves the generator a round trip out
        # through the NAT gateway; avatar_url remains the fallback for users
        # with no attached avatar, and means this deploys independently of the
        # generator change.
        avatar_data: User::AvatarDataUri.(solution.user),
        avatar_url: solution.user.avatar_url,
        exercise_title: solution.exercise.title,
        track_title: solution.track.title
      },
      highlight_theme: SerializeHighlightjsTheme.()
    }
  end

  private
  def iteration = @iteration ||= solution.latest_published_iteration

  def files
    return [] if iteration.blank?

    iteration.files.map do |file|
      { filename: file.filename, content: file.content }
    end
  end
end
