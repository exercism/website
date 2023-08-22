module ApplicationCable
  class Channel < ActionCable::Channel::Base
    # As we don't identify by current_user, we have
    # to manually delegate to the connection here
    # delegate :current_user, to: :connection
    # delegate :connection_identifier, to: :connection
  end
end
