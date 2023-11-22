module ViewComponents
  class DocsSideNav < ViewComponent
    extend Mandate::Memoize

    def initialize(docs, selected_doc, track: nil)
      super()

      @docs = docs.includes(:track)
      @selected_doc = selected_doc
      @track = track
    end

    def to_s
      tag.nav(class: "c-docs-side-nav") do
        tags = []
        tags << tag.h2(@track.title) if track
        tags << tag.input(class: 'side-menu-trigger', id: 'side-menu-trigger', type: 'checkbox', style: 'display: none')
        tags << hamburger
        tags << tag.ul(class: 'c-docs-side-nav-ul', data: { scrollable_container: true }) do
          safe_join(
            structured_docs.map do |node, children|
              render_section(node, children)
            end
          )
        end
        safe_join(tags.compact)
      end
    end

    def hamburger
      tag.label(for: 'side-menu-trigger', class: 'trigger-label') do
        safe_join([
                    tag.span(class: 'icon-bar top-bar'),
                    tag.span(class: 'icon-bar middle-bar'),
                    tag.span(class: 'icon-bar bottom-bar')
                  ])
      end
    end

    private
    attr_reader :docs, :selected_doc, :track

    def render_section(node, children)
      return if node.blank? && children.blank?

      tags = []
      tags << doc_li(node, children) if node.present?

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

    def doc_li(slug, children)
      return if slug.blank?

      doc = indexed_docs[slug]
      return unless doc # TODO: (Optional) Delete this

      if doc.track
        url = Exercism::Routes.track_doc_path(doc.track, doc)
      elsif doc.apex?
        url = Exercism::Routes.docs_section_path(doc.section)
      else
        url = Exercism::Routes.doc_path(doc.section, doc.slug)
      end

      css_classes = []
      css_classes << "selected expanded" if doc.slug == selected_doc&.slug
      scroll_into_view = ScrollAxis::Y if doc.slug == selected_doc&.slug
      css_classes << "header" if slugs_with_children.include?(doc.slug)
      css_classes << "expanded" if flatten_hash(children).any? { |c| c == selected_doc&.slug }

      tag.li(class: css_classes.join(" "), data: { scroll_into_view: }) do
        link_to tag.span(doc.nav_title), url
      end
    end

    memoize
    def indexed_docs
      docs.index_by(&:slug)
    end

    memoize
    def structured_docs
      levels = []
      current = ""
      selected_doc&.slug.to_s.split("/").each do |part|
        current += "#{part}/"
        levels << current
      end

      paths = docs.map(&:slug).sort
      paths.each_with_object({}) do |path, tree|
        # Only get docs that are:
        # - top level
        # - at a level below this in its path
        # - parallel to it; or
        # - a direct-child of the current doc
        level = path.count("/")
        next unless level.zero? ||
                    (levels.size >= level && path.starts_with?(levels[level - 1]))

        parts = path.split('/')
        current = tree
        parts.each_with_index do |_part, i|
          node = parts[0..i].join('/')
          current[node] = {} unless current.key?(node)
          current = current[node]
        end
      end
    end

    memoize
    def slugs_with_children
      paths = docs.map(&:slug).sort
      paths.select do |path|
        paths.any? { |otherpath| otherpath != path && otherpath.start_with?("#{path}/") }
      end
    end

    def flatten_hash(hash)
      res = []
      hash.each do |key, values|
        res << key if key.present?
        res << values.flat_map { |v| flatten_hash(v) } if values
      end
      res.flatten
    end
  end
end
