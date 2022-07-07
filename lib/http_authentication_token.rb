module HttpAuthenticationToken
  def self.from_header(header)
    token = header.to_s.match(/^Token (.*)/) { |m| m[1] }
    return nil unless token

    values = Hash[token.split(",").map do |value|
      value.strip! # remove any spaces between commas and values
      key, value = value.split(/="?/) # split key=value pairs
      value.chomp!('"') # chomp trailing " in value
      value.gsub!(/\\"/, '"') # unescape remaining quotes
      [key, value]
    end]
    values["token"]
  rescue StandardError
    nil
  end
end
