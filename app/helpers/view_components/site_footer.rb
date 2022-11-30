module ViewComponents
  class SiteFooter < ViewComponent
    extend Mandate::Memoize

    delegate :namespace_name, :controller_name,
      to: :view_context

    def to_s
      digests = %w[external shared].map do |file|
        Digest::SHA1.hexdigest(File.read(Rails.root.join('app', 'views', 'components', 'footer', "#{file}.html.haml")))
      end
      Rails.cache.fetch("#{digests.join(':')}:#{::Track.active.count}:#{user_signed_in? ? current_user.captcha_required? : 0}") do
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
