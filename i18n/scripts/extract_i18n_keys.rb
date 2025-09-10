#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'find'

# This script extracts all i18n keys from the Exercism codebase
class I18nKeyExtractor
  def initialize
    @keys_with_context = {}
    @locale_keys = {}
  end

  def extract_all
    puts "Extracting i18n keys from Exercism codebase..."

    # Extract from locale files first to understand the structure
    extract_locale_files

    # Extract from HAML files (Rails view files)
    extract_haml_files

    # Extract from Ruby files
    extract_ruby_files

    # Extract from ERB files
    extract_erb_files

    # Generate final JSON
    generate_json
  end

  private
  def extract_locale_files
    puts "Processing locale files..."
    Dir.glob("config/locales.bk/**/*.yml") do |file|
      data = YAML.load_file(file)
      flatten_hash(data, [], file)
    rescue StandardError => e
      puts "Error processing #{file}: #{e.message}"
    end
  end

  def flatten_hash(hash, prefix = [], file_path = "")
    hash.each do |key, value|
      new_key = prefix + [key]
      if value.is_a?(Hash)
        flatten_hash(value, new_key, file_path)
      elsif new_key.length > 1
        # Skip the language prefix (en:, hu:, etc.)
        full_key = new_key[1..-1].join('.')
        @locale_keys[full_key] = {
          value: value,
          file: file_path,
          type: "locale_definition"
        }
      end
    end
  end

  def extract_haml_files
    puts "Processing HAML files..."
    Find.find("app/views") do |path|
      next unless path.end_with?('.haml')

      content = File.read(path)

      # Find t('.key') patterns
      content.scan(/= t\('\.([^']+)'.*?\)/) do |match|
        relative_key = match[0]
        full_key = haml_path_to_key(path, relative_key)
        add_key_with_context(full_key, path, content, "haml_relative")
      end

      # Find t('full.key') patterns
      content.scan(/= t\('([^'.][^']+)'.*?\)/) do |match|
        full_key = match[0]
        add_key_with_context(full_key, path, content, "haml_absolute")
      end

      # Find I18n.t patterns
      content.scan(/I18n\.t\(['"']([^'"]+)['"].*?\)/) do |match|
        full_key = match[0]
        add_key_with_context(full_key, path, content, "haml_i18n")
      end
    end
  end

  def extract_ruby_files
    puts "Processing Ruby files..."
    Find.find("app") do |path|
      next unless path.end_with?('.rb')

      content = File.read(path)

      # Find I18n.t patterns
      content.scan(/I18n\.t\(['"']([^'"]+)['"].*?\)/) do |match|
        full_key = match[0]
        add_key_with_context(full_key, path, content, "ruby_i18n")
      end

      # Find t() patterns
      content.scan(/\bt\(['"']([^'"]+)['"].*?\)/) do |match|
        full_key = match[0]
        add_key_with_context(full_key, path, content, "ruby_t")
      end
    end
  end

  def extract_erb_files
    puts "Processing ERB files..."
    Find.find("app/views") do |path|
      next unless path.end_with?('.erb')

      content = File.read(path)

      # Find t patterns
      content.scan(/<%= t\('([^']+)'.*?\) %>/) do |match|
        full_key = match[0]
        add_key_with_context(full_key, path, content, "erb")
      end
    end
  end

  def haml_path_to_key(file_path, relative_key)
    # Convert HAML file path to i18n key path
    # app/views/mentoring/external/show.html.haml -> mentoring.external.show
    path_parts = file_path.gsub(%r{^app/views/}, '').gsub(/\.html\.haml$/, '').split('/')
    "#{path_parts.join('.')}.#{relative_key}"
  end

  def add_key_with_context(key, file_path, content, source_type)
    @keys_with_context[key] ||= []

    # Find the line with the key for context
    lines = content.split("\n")
    context_line = lines.find { |line| line.include?(key) } || ""

    @keys_with_context[key] << {
      file: file_path,
      context_line: context_line.strip,
      source_type: source_type
    }
  end

  def generate_json
    puts "Generating comprehensive JSON..."

    final_keys = {}

    # Process all discovered keys
    (@keys_with_context.keys + @locale_keys.keys).uniq.each do |key|
      usage_info = @keys_with_context[key] || []
      locale_info = @locale_keys[key]

      description = generate_description(key, usage_info, locale_info)
      final_keys[key] = description
    end

    # Write to JSON file
    File.write('complete_i18n_keys_descriptions.json', JSON.pretty_generate(final_keys))

    puts "Generated complete_i18n_keys_descriptions.json with #{final_keys.size} keys"
    puts "Found #{@keys_with_context.size} keys from usage analysis"
    puts "Found #{@locale_keys.size} keys from locale files"
  end

  def generate_description(key, usage_info, locale_info)
    description_parts = []

    # Add basic information about the key
    description_parts << "Translation key: #{key}"

    # Add locale file information if available
    if locale_info
      description_parts << "Defined in locale file: #{locale_info[:file]}"
      description_parts << "Current English text: \"#{locale_info[:value]}\""
    end

    # Add usage information
    if usage_info && usage_info.any?
      description_parts << "Usage locations:"
      usage_info.each do |usage|
        case usage[:source_type]
        when "haml_relative" then file_type = "HAML view (relative key)"
        when "haml_absolute" then file_type = "HAML view (absolute key)"
        when "haml_i18n" then file_type = "HAML view (I18n.t)"
        when "ruby_i18n" then file_type = "Ruby file (I18n.t)"
        when "ruby_t" then file_type = "Ruby file (t method)"
        when "erb" then file_type = "ERB view"
        else file_type = usage[:source_type]
        end

        description_parts << "- #{usage[:file]} (#{file_type}): #{usage[:context_line]}"
      end
    end

    # Generate contextual description based on key structure and usage
    contextual_desc = generate_contextual_description(key, usage_info, locale_info)
    description_parts << "Context: #{contextual_desc}" if contextual_desc

    description_parts.join("\n")
  end

  def generate_contextual_description(key, usage_info, _locale_info)
    # Generate smart descriptions based on key patterns and usage
    key_parts = key.split('.')

    # Analyze key structure for context clues
    context_clues = []

    context_clues << "This is a button label" if key_parts.include?('button') || key.include?('btn')

    context_clues << "This is a heading or title text" if key_parts.include?('heading') || key_parts.include?('title')

    context_clues << "This is descriptive text" if key_parts.include?('description') || key_parts.include?('subtitle')

    context_clues << "This is an error or warning message" if key_parts.include?('error') || key_parts.include?('warning')

    context_clues << "This appears in a modal dialog" if key_parts.include?('modal')

    context_clues << "This appears in a tooltip" if key_parts.include?('tooltip')

    # Add page/section context from file paths
    if usage_info && usage_info.any?
      file_context = usage_info.first[:file]
      if file_context.include?('app/views/')
        page_path = file_context.gsub(%r{^app/views/}, '').gsub(/\.(html\.haml|html\.erb)$/, '')
        context_clues << "Used in #{page_path} page/section"
      end
    end

    context_clues.any? ? context_clues.join('. ') : nil
  end
end

# Run the extraction
extractor = I18nKeyExtractor.new
extractor.extract_all
