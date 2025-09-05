#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

# Create merged locale.yaml from locales.bk directory
# This script properly merges all YAML files and removes the "en" prefix

OUTPUT_FILE = "config/locale.yaml"
LOCALES_DIR = "config/locales.bk"

puts "Merging locale files from #{LOCALES_DIR} into #{OUTPUT_FILE}"

# Collect all YAML content
merged_data = {}

# Process all .yml files in locales.bk directory
Dir.glob("#{LOCALES_DIR}/**/*.yml").each do |file|
  puts "Processing #{file}"
  
  begin
    data = YAML.load_file(file) || {}
    en_data = data['en'] || {}
    
    # Deep merge the en_data into merged_data
    def deep_merge!(target, source)
      source.each do |key, value|
        if target[key].is_a?(Hash) && value.is_a?(Hash)
          deep_merge!(target[key], value)
        else
          target[key] = value
        end
      end
      target
    end
    
    deep_merge!(merged_data, en_data)
  rescue => e
    puts "Error processing #{file}: #{e}"
    next
  end
end

# Write the merged data to the output file
File.write(OUTPUT_FILE, YAML.dump(merged_data))

puts "Merge complete. Output written to #{OUTPUT_FILE}"
puts "File size: #{File.readlines(OUTPUT_FILE).count} lines"
puts "Keys found: #{merged_data.keys.count}"
