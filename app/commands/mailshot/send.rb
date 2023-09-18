class Mailshot
  class Send
    include Mandate

    initialize_with :mailshot, :audience_type, :audience_slug

    def call
      # Start the daisy chain of sending
      Mailshot::SendToAudienceSegment.defer(mailshot, audience_type, audience_slug, 100, 0)

      # Update the record with this audience as sent to
      audience = "#{audience_type}##{audience_slug}".gsub(/\#$/, "")
      mailshot.update!(
        sent_to_audiences: mailshot.sent_to_audiences.add(audience)
      )
    end
  end
end
