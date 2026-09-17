class ViewComponents::Track::Build::Health < ViewComponents::ViewComponent
  initialize_with :health_status, plural: false

  def to_s = tag.span(text, class:)

  private
  def text
    case health_status.to_sym
    when :exemplar
      I18n.t("components.track.build.health.exemplar", verb:)
    when :healthy
      I18n.t("components.track.build.health.healthy", verb:)
    when :needs_attention
      I18n.t("components.track.build.health.needs_attention")
    else
      I18n.t("components.track.build.health.missing", verb:)
    end
  end

  def class
    case health_status.to_sym
    when :exemplar
      "text-healthyGreen"
    when :healthy
      "text-healthyGreen"
    when :needs_attention
      "text-warning"
    else
      "text-textColor6"
    end
  end

  def verb = plural ? I18n.t("components.track.build.health.verb.plural") : I18n.t("components.track.build.health.verb.singular")
end
