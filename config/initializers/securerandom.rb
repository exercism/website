require 'securerandom'

module SecureRandom
  def self.compact_uuid
    SecureRandom.uuid.gsub('-', '')
  end
end
