module FlashHelper
  def flash_messages(object = nil, html_messages: false)
    tags = []
    a = alert
    n = notice

    # rubocop:disable Rails/HelperInstanceVariable
    if devise_controller? && @user && @user.errors.full_messages.present?
      if html_messages
        errors = @user.errors.full_messages.join("<br/>").html_safe
      else
        errors = safe_join(@user.errors.full_messages, "<br/>".html_safe)
      end
      tags << tag.div(errors, class: '--errors')
    end
    # rubocop:enable Rails/HelperInstanceVariable

    if object && object.errors.full_messages.present?
      errors = safe_join(object.errors.full_messages, "<br/>".html_safe)
      tags << tag.div(errors, class: '--errors')
    end

    tags << tag.div(n, class: "--notice") if n.present?
    tags << tag.div((html_messages ? raw(a) : a), class: "--alert") if a.present?

    tags.present? ? tag.div(safe_join(tags), class: "c-flash") : nil
  end
end
