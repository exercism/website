# frozen_string_literal: true

require "csv"

TSV_FILE = Rails.root.join("i18n/glossary_base.tsv")

def import_glossary
  puts "📂 Importing glossary terms from #{TSV_FILE}"

  user = User.system_user
  
  CSV.foreach(TSV_FILE, col_sep: "\t", headers: true, encoding: "UTF-8", quote_char: nil) do |row|
    term = row["term"]&.strip
    llm_instructions = row["llm_instructions"]&.strip
    
    next if term.blank? || llm_instructions.blank?
    
    # For English glossary entries, use the term itself as the translation
    Localization::GlossaryEntry::Create.(user, "en", term, term, llm_instructions)
    puts " → #{term}"
  rescue ActiveRecord::RecordNotUnique
    # Already exists, skip
    puts " ⚠️ Skipped #{term} (already exists)"
  rescue StandardError => e
    puts " ❌ Failed to import #{term}: #{e.message}"
  end
end

import_glossary