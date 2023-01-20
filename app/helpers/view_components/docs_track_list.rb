module ViewComponents
  class DocsTrackList < ViewComponent
    extend Mandate::Memoize

    def to_s
      track_divs = tracks.map do |track|
        link_to(Exercism::Routes.track_docs_path(track), class: "track") do
          safe_join(
            [
              track_icon(track),
              tag.div(track.title, class: 'title'),
              tag.div(pluralize(doc_counts[track.id], "doc"), class: 'count')
            ]
          )
        end
      end
      tag.div(class: "c-docs-tracks-list") do
        tag.div(safe_join(track_divs), class: "tracks")
      end
    end

    private
    memoize
    def tracks
      ::Track.active.order(:title)
    end

    memoize
    def doc_counts
      ::Document.group(:track_id).count
    end
  end
end
