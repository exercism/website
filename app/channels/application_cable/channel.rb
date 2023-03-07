module ApplicationCable
  class Channel < ActionCable::Channel::Base
    delegate :current_user, to: :connection
  end
end
