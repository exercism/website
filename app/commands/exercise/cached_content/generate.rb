# Reads an exercise's introduction and instructions from git and parses
# them to HTML. This is the expensive work the cache exists to avoid: a
# git read per document plus a full markdown parse and sanitisation pass.
#
# When there is a solution we render its content rather than the
# exercise's, because a solution pins the git sha it was created at and
# must keep showing the instructions it was started against.
class Exercise::CachedContent::Generate
  include Mandate

  initialize_with :exercise, :solution

  def call
    {
      introduction: Markdown::Parse.(source.introduction),
      instructions: Markdown::Parse.(source.instructions)
    }
  end

  private
  def source = solution || exercise
end
