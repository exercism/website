module HttpAuthenticationToken
  def self.from_header(header)
    token = header.to_s.match(/^Token (.*)/) { |m| m[1] }
    return nil unless token

    token.split(",").find do |kv|
      key, value = kv.strip.split(/="?/)
      return value.chomp('"').gsub(/\\"/, '"') if key == 'token'
    end
  rescue StandardError
    nil
  end
end
