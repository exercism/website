# frozen_string_literal: true

require "json"

# Directory containing your TS files
DIR = Rails.root.join("app/javascript/i18n/en")

PAIR_REGEX = /
  ['"](?<key>[^'"]+)['"]      # key
  \s*:\s*
  (?<val>
    "(?:[^"\\]|\\.)*"         # double-quoted string
    |
    '(?:[^'\\]|\\.)*'         # single-quoted string
  )
/x


def import_file(file_path)
  puts "📂 Importing #{file_path}"
  content = File.read(file_path)

  content.scan(PAIR_REGEX) do |key, raw_val|
    value = raw_val[1..-2] # strip surrounding quotes
    value = value.gsub("\\'", "'").gsub('\\"', '"')

    Localization::Original::Create.(:website_client_side, key, value, nil, false)
    # puts " → #{key} = #{value}"
  rescue ActiveRecord::RecordNotUnique 
    # Skip
  rescue ActiveRecord::RecordInvalid => e
    puts "⚠️ Failed to import #{key}: #{e.message}"
  end
end

Dir.glob(DIR.join("*.ts")).each do |file|
  import_file(file)
end