module ViewComponents
  class DocsSideNav < ViewComponent
    extend Mandate::Memoize

    def initialize(docs, selected_doc, track: nil)
      super

      @docs = docs
      @selected_doc = selected_doc
      @track = track
    end

    def to_s
      tag.nav(class: "c-docs-side-nav") do
        tags = []
        tags << tag.h2(@track.title) if track
        tags << tag.ul do
          safe_join(
            structured_docs.map do |node, children|
              render_section(node, children)
            end
          )
        end
        safe_join(tags.compact)
      end
    end

    private
    attr_reader :docs, :selected_doc, :track

    def render_section(node, children)
      return if node.blank? && children.blank?

      tags = []
      tags << doc_li(node) if node.present?

      if children.present?
        tags << tag.li do
          tag.ul do
            safe_join(
              children.map do |child, grandchildren|
                render_section(child, grandchildren)
              end
            )
          end
        end
      end

      tags
    end

    def doc_li(slug)
      return if slug.blank?

      doc = indexed_docs[slug]
      return unless doc # TODO: Delete this

      if doc.track
        url = Exercism::Routes.track_doc_path(doc.track, doc)
      elsif doc.apex?
        url = Exercism::Routes.doc_section_path(doc.section)
      else
        url = Exercism::Routes.doc_path(doc.section, doc.slug)
      end

      tag.li(class: doc == selected_doc ? "selected" : nil) do
        link_to doc.nav_title, url
      end
    end

    memoize
    def indexed_docs
      docs.index_by(&:slug)
    end

    memoize
    def structured_docs
      paths = docs.map(&:slug)
      paths.each_with_object({}) do |path, tree|
        parts = path.split('/')
        current = tree
        parts.each_with_index do |_part, i|
          node = parts[0..i].join('/')
          current[node] = {} unless current.key?(node)
          current = current[node]
        end
      end
    end
  end
end
