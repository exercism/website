module ApplicationCable
  class Connection < ActionCable::Connection::Base
    attr_accessor :current_user

    identified_by :connection_identifier

    def connect
      self.current_user = env["warden"].user(:user)
    end

    # We don't require a user to be authenticated
    # If they're not, we'll just generated a random
    # one off id for this connection (browser tab)
    def connection_identifier
      current_user || SecureRandom.uuid
    end
  end
end
