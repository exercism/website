# frozen_string_literal: true
require "yaml"

DIRS = [
  Rails.root.join("config/locales"),
  Rails.root.join("config/locales.bk")
]

# Flatten nested YAML into dot-notation keys
def flatten_keys(obj, prefix = "")
  result = {}

  case obj
  when Hash
    obj.each do |k, v|
      # Always stringify keys (so "1" instead of integer 1)
      k = k.to_s
      full_key = prefix.empty? ? k : "#{prefix}.#{k}"
      result.merge!(flatten_keys(v, full_key))
    end
  else
    # leaf value
    result[prefix] = obj
  end

  result
end

def import_file(file_path)
  puts "📂 Importing #{file_path}"
  data = YAML.load_file(file_path) || {}

  flatten_keys(data).each do |key, value|
    next if value.nil?                      # skip nils
    next unless key.start_with?("en.")      # only keep English keys

    stripped_key = key.sub(/^en\./, "")     # remove "en." prefix

    Localization::Original::Create.(:website_server_side, stripped_key, value, nil, false)
    # puts " → #{stripped_key} = #{value.inspect}"
  rescue ActiveRecord::RecordNotUnique
    # Already added
  end
end

DIRS.each do |dir|
  Dir.glob(dir.join("**/*.yml")).each do |file|
    import_file(file)
  end
end