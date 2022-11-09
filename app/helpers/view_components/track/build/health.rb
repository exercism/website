class ViewComponents::Track::Build::Health < ViewComponents::ViewComponent
  initialize_with :health_status

  def to_s = tag.span(text, class:)

  private
  def text
    case health_status.to_sym
    when :exemplar
      "exemplar ✨"
    when :healthy
      "healthy ✅"
    when :needs_attention
      "needs attention ⚠️"
    else
      "missing ❌"
    end
  end

  def class
    case health_status.to_sym
    when :exemplar
      "text-textColor6"
    when :healthy
      "text-healthyGreen"
    when :needs_attention
      "text-warning"
    else
      "text-warning"
    end
  end
end
