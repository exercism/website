# Reads a concept's about and introduction documents from git and parses
# them to HTML. This is the expensive work the cache exists to avoid: a
# git read per document plus a full markdown parse and sanitisation pass.
#
# Both documents are generated together because which one the page shows
# depends on the viewer, so caching them as a pair keeps it to one read.
class Concept::CachedContent::Generate
  include Mandate

  initialize_with :concept

  def call
    {
      about: Markdown::Parse.(concept.about),
      introduction: Markdown::Parse.(concept.introduction)
    }
  end
end
