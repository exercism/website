require 'securerandom'

module SecureRandom
  def self.compact_uuid
    SecureRandom.uuid.delete('-')
  end
end
