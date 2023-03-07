module ApplicationCable
  class Connection < ActionCable::Connection::Base
    attr_accessor :current_user

    identified_by :connection_identifier

    def connect
      self.current_user = env["warden"].user(:user)
    end

    def connection_identifier
      current_user || SecureRandom.uuid
    end
  end
end
