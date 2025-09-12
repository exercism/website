#!/usr/bin/env ruby

# This script imports glossary translations from TSV files in i18n/glossary/
# and creates database entries using Localization::GlossaryEntry::Create
#
# Usage: rails runner scripts/import_glossary_translations.rb [locale]
#
# Examples:
#   rails runner scripts/import_glossary_translations.rb        # Import all locales
#   rails runner scripts/import_glossary_translations.rb hu     # Import only Hungarian

require 'csv'

class GlossaryImporter
  def initialize(locale = nil)
    @locale = locale
    @glossary_dir = Rails.root.join('i18n', 'glossary')
  end

  def import!
    files_to_import.each do |file|
      import_file(file)
    end
  end

  private

  def files_to_import
    if @locale
      file = @glossary_dir.join("#{@locale}.tsv")
      if File.exist?(file)
        [file]
      else
        puts "File not found: #{file}"
        []
      end
    else
      Dir.glob(@glossary_dir.join('*.tsv'))
    end
  end

  def import_file(file)
    locale = File.basename(file, '.tsv')
    puts "Importing glossary for locale: #{locale}"
    
    imported = 0
    skipped = 0
    errors = []

    user = User.system_user

    CSV.foreach(file, col_sep: "\t", headers: true, liberal_parsing: true) do |row|
      term = row['term']
      translation = row['translation']
      llm_instructions = row['llm_instructions']

      # Skip if any required field is missing
      if term.blank? || translation.blank?
        skipped += 1
        puts "  Skipping row with missing term or translation"
        next
      end

      begin
        # Create new entry (Create service should handle updates if needed)
        Localization::GlossaryEntry::Create.(
          user,
          locale,
          term,
          translation,
          llm_instructions
        )
        imported += 1
        puts "  Imported: #{term} -> #{translation}"
      rescue => e
        errors << { term: term, error: e.message }
        puts "  ERROR importing '#{term}': #{e.message}"
      end
    end

    puts "\nSummary for #{locale}:"
    puts "  Imported: #{imported}"
    puts "  Skipped: #{skipped}"
    puts "  Errors: #{errors.count}"
    
    if errors.any?
      puts "\nErrors details:"
      errors.each do |err|
        puts "  - #{err[:term]}: #{err[:error]}"
      end
    end
  end
end

# Run the importer
locale = ARGV[0]

if locale == '--help' || locale == '-h'
  puts "Usage: rails runner scripts/import_glossary_translations.rb [locale]"
  puts ""
  puts "Examples:"
  puts "  rails runner scripts/import_glossary_translations.rb        # Import all locales"
  puts "  rails runner scripts/import_glossary_translations.rb hu     # Import only Hungarian"
  puts ""
  puts "Available glossary files:"
  Dir.glob(Rails.root.join('i18n', 'glossary', '*.tsv')).each do |file|
    locale = File.basename(file, '.tsv')
    line_count = File.readlines(file).size - 1 # Subtract header
    puts "  - #{locale} (#{line_count} terms)"
  end
else
  importer = GlossaryImporter.new(locale)
  importer.import!
end