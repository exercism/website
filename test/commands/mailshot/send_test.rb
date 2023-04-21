require 'test_helper'

class Mailshot::SendTestTest < ActiveSupport::TestCase
  test "sends to audience" do
    mailshot = create :mailshot
    audience_type = "track"
    audience_slug = "elixir"

    Mailshot::SendToAudienceSegment.expects(:defer).with(mailshot, audience_type, audience_slug, 100, 0)

    Mailshot::Send.(mailshot, audience_type, audience_slug)
  end

  test "updates record" do
    mailshot = create :mailshot

    Mailshot::Send.(mailshot, "track", "elixir")
    assert_equal ["track#elixir"], mailshot.sent_to_audiences.to_a

    Mailshot::Send.(mailshot, :admins, nil)
    assert_equal ["track#elixir", "admins"], mailshot.sent_to_audiences.to_a
  end
end
