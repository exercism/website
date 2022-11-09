class ViewComponents::Track::Build::Health < ViewComponents::ViewComponent
  initialize_with :health_status, plural: false

  def to_s = tag.span(text, class:)

  private
  def text
    case health_status.to_sym
    when :exemplar
      "#{person} exemplar ✨"
    when :healthy
      "#{person} healthy ✅"
    when :needs_attention
      "needs attention ⚠️"
    else
      "#{person}  missing ❓"
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

  def person = plural ? 'are' : 'is'
end
