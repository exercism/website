# frozen_string_literal: true

require "yaml"

class LoadLocaleIntoDB
  def self.call
    new.()
  end

  def call
    puts "📂 Loading locale.yaml into database"

    data = YAML.load_file(locale_file) || {}
    flatten_keys(data).each do |key, value|
      next if value.nil?

      # Create the Original record
      original = Localization::Original::Create.(:website_server_side, key, value, nil, false)

      # Create the Translation record for English
      Localization::Translation.create!(
        original: original,
        locale: "en",
        key: key,
        value: value
      )
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      # Already added
    end
  end

  private
  def locale_file
    Rails.root.join("config", "locale.yaml")
  end

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
end
