module ViewComponents
  class SiteFooter < ViewComponent
    extend Mandate::Memoize

    delegate :render_site_header?,
      :namespace_name, :controller_name,
      to: :view_context

    def to_s
      return unless render_site_header?

      digests = %w[external shared].map do |file|
        Digest::SHA1.hexdigest(File.read(Rails.root.join('app', 'views', 'components', 'footer', "#{file}.html.haml")))
      end
      Rails.cache.fetch("#{digests.join(':')}:#{user_signed_in? ? 1 : 0}") do
        tag.footer(id: "site-footer") do
          parts = []
          parts << render(template: 'components/footer/external') unless user_signed_in?
          parts << render(template: 'components/footer/shared')
          safe_join(parts)
        end
      end
    end
  end
end
