class Mailshot < ApplicationRecord
  has_markdown_field :content, strip_h1: false

  def email_communication_preferences_key
    super&.to_sym
  end
end
