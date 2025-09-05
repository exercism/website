#!/usr/bin/env ruby

require 'json'
require 'yaml'

class I18nDescriptionEnhancer
  def initialize
    @enhanced_descriptions = {}
    @usage_patterns = {}
    @locale_data = {}
    load_locale_data
  end

  def enhance_descriptions
    puts "Loading existing descriptions..."
    existing_data = JSON.parse(File.read('complete_i18n_keys_descriptions.json'))

    puts "Enhancing descriptions for #{existing_data.size} keys..."

    existing_data.each do |key, description|
      enhanced_desc = create_enhanced_description(key, description)
      @enhanced_descriptions[key] = enhanced_desc
    end

    # Write enhanced version
    File.write('complete_i18n_keys_descriptions.json', JSON.pretty_generate(@enhanced_descriptions))

    puts "Enhanced descriptions complete!"
    puts "Generated enhanced file with #{@enhanced_descriptions.size} keys"
  end

  private
  def load_locale_data
    puts "Loading locale data for context analysis..."
    Dir.glob("config/locales.bk/**/*.yml") do |file|
      data = YAML.load_file(file)
      @locale_data[file] = data
    rescue StandardError => e
      puts "Error loading #{file}: #{e.message}"
    end
  end

  def create_enhanced_description(key, original_description)
    key_parts = key.split('.')

    # Extract current English text from original description
    english_text = extract_english_text(original_description)

    # Generate comprehensive description
    enhanced_parts = []

    # 1. Functional Purpose
    functional_purpose = determine_functional_purpose(key, key_parts, english_text)
    enhanced_parts << "**Functional Purpose**: #{functional_purpose}"

    # 2. UI Context and Location
    ui_context = determine_ui_context(key, key_parts, original_description)
    enhanced_parts << "**UI Location**: #{ui_context}"

    # 3. User Context
    user_context = determine_user_context(key, key_parts, english_text)
    enhanced_parts << "**When Users See This**: #{user_context}"

    # 4. Technical Context
    technical_context = determine_technical_context(key, key_parts, original_description)
    enhanced_parts << "**Technical Context**: #{technical_context}"

    # 5. Translation Notes
    translation_notes = generate_translation_notes(key, key_parts, english_text)
    enhanced_parts << "**Translation Notes**: #{translation_notes}" if translation_notes

    # 6. Current English Text
    enhanced_parts << "**Current English**: \"#{english_text}\"" if english_text

    # 7. File Usage Information
    usage_info = extract_usage_info(original_description)
    enhanced_parts << "**Usage**: #{usage_info}" if usage_info

    enhanced_parts.join("\n\n")
  end

  def extract_english_text(description)
    match = description.match(/Current English text: "([^"]+)"/)
    match ? match[1] : nil
  end

  def extract_usage_info(description)
    if description.include?("Usage locations:")
      lines = description.split("\n")
      usage_start = lines.find_index { |line| line.include?("Usage locations:") }
      return nil unless usage_start

      usage_lines = lines[(usage_start + 1)..-1].select { |line| line.start_with?("- ") }
      return usage_lines.join("\n") if usage_lines.any?
    end
    nil
  end

  def determine_functional_purpose(_key, key_parts, english_text)
    purposes = []

    # Button/Action analysis
    if key_parts.any? { |part| %w[button btn action submit cancel confirm].include?(part) }
      purposes << "Interactive button that triggers an action"
    end

    # Heading/Title analysis
    if key_parts.any? { |part| %w[heading title header].include?(part) }
      purposes << "Page or section heading that structures content hierarchy"
    end

    # Description/Info analysis
    if key_parts.any? { |part| %w[description subtitle info explanation].include?(part) }
      purposes << "Explanatory text that provides information to users"
    end

    # Error/Warning analysis
    if key_parts.any? { |part| %w[error warning notice alert].include?(part) }
      purposes << "Status message informing users of system state or required actions"
    end

    # Form/Input analysis
    if key_parts.any? { |part| %w[placeholder label hint validation].include?(part) }
      purposes << "Form interface element guiding user input"
    end

    # Navigation analysis
    if key_parts.any? { |part| %w[nav menu link tab breadcrumb].include?(part) }
      purposes << "Navigation element helping users move through the interface"
    end

    # Modal/Dialog analysis
    if key_parts.any? { |part| %w[modal dialog popup tooltip].include?(part) }
      purposes << "Overlay interface element providing focused interaction"
    end

    # Email/Notification analysis
    if key_parts.any? { |part| %w[mailer notification email subject].include?(part) }
      purposes << "Communication text sent to users via email or notifications"
    end

    # If no specific purpose identified, make a smart guess based on English text
    if purposes.empty?
      if english_text
        if /\?$/.match?(english_text)
          purposes << "Question or prompt asking for user input or decision"
        elsif /!$/.match?(english_text)
          purposes << "Emphatic statement or call-to-action"
        elsif english_text.length < 50
          purposes << "Label or short informational text"
        else
          purposes << "Informational content providing context or instructions"
        end
      else
        purposes << "Interface text element"
      end
    end

    purposes.join(". ")
  end

  def determine_ui_context(_key, key_parts, original_description)
    contexts = []

    # Extract page context from key structure
    if key_parts.length >= 2
      page_section = key_parts[0..1].join('/')
      contexts << "Located in the #{page_section.tr('_', ' ')} section"
    end

    # Modal/popup context
    contexts << "Appears in a modal dialog or popup overlay" if key_parts.any? { |part| %w[modal popup dialog tooltip].include?(part) }

    # Header/footer context
    contexts << "Part of the site navigation or layout structure" if key_parts.any? { |part| %w[header footer nav].include?(part) }

    # Settings/preferences context
    if key_parts.any? { |part| %w[settings preferences profile].include?(part) }
      contexts << "Found in user settings or profile configuration area"
    end

    # Exercise/track context
    if key_parts.any? { |part| %w[exercise track solution mentoring].include?(part) }
      contexts << "Related to the core learning experience (exercises, tracks, or mentoring)"
    end

    # Form context
    contexts << "Part of a form or data input interface" if key_parts.any? { |part| %w[form field input].include?(part) }

    # Extract file-based context from original description
    if original_description.include?("app/views/")
      file_match = original_description.match(%r{app/views/([^/]+)/([^/\s]+)})
      if file_match
        controller = file_match[1].tr('_', ' ')
        action = file_match[2].tr('_', ' ')
        contexts << "Displayed on the #{controller} #{action} page"
      end
    end

    # If no context found, provide generic context
    contexts << "Part of the web interface" if contexts.empty?

    contexts.join(". ")
  end

  def determine_user_context(_key, key_parts, english_text)
    contexts = []

    # Authentication context
    if key_parts.any? { |part| %w[login register signup signin auth devise].include?(part) }
      contexts << "During user authentication process (login, registration, password reset)"
    end

    # Learning context
    if key_parts.any? { |part| %w[exercise track solution iteration].include?(part) }
      contexts << "While students are working through programming exercises and learning"
    end

    # Mentoring context
    if key_parts.any? { |part| %w[mentor discussion request].include?(part) }
      contexts << "During mentoring interactions between students and mentors"
    end

    # Settings context
    if key_parts.any? { |part| %w[settings preferences profile].include?(part) }
      contexts << "When users are configuring their account settings or preferences"
    end

    # Error context
    if key_parts.any? { |part| %w[error warning validation].include?(part) }
      contexts << "When there's an error, warning, or validation issue that needs user attention"
    end

    # Progress/achievement context
    if key_parts.any? { |part| %w[badge trophy achievement reputation progress].include?(part) }
      contexts << "When users are viewing their progress, achievements, or reputation"
    end

    # Community context
    if key_parts.any? { |part| %w[community contribution forum].include?(part) }
      contexts << "During community interactions and contributions to Exercism"
    end

    # Onboarding context
    if key_parts.any? { |part| %w[onboarding welcome intro].include?(part) }
      contexts << "During initial user onboarding and introduction to Exercism"
    end

    # Generic context based on English text patterns
    if contexts.empty? && english_text
      if /^(Welcome|Hello|Hi)/.match?(english_text)
        contexts << "As a greeting or welcome message"
      elsif /^(Click|Press|Select|Choose)/.match?(english_text)
        contexts << "When providing instructions for user actions"
      elsif /\?$/.match?(english_text)
        contexts << "When the system needs user input or decision"
      else
        contexts << "During normal use of the Exercism platform"
      end
    end

    contexts << "During general use of the Exercism platform" if contexts.empty?

    contexts.join(". ")
  end

  def determine_technical_context(key, key_parts, original_description)
    contexts = []

    # HTML interpolation
    contexts << "Contains HTML markup that must be preserved in translation" if key.end_with?('_html')

    # Variable interpolation
    if original_description.include?('%{')
      vars = original_description.scan(/%\{([^}]+)\}/).flatten.uniq
      contexts << "Contains dynamic variables: #{vars.map { |v| "%{#{v}}" }.join(', ')} - these must remain unchanged"
    end

    # Pluralization
    if key_parts.any? { |part| %w[one other zero few many].include?(part) }
      contexts << "Part of a pluralization rule - the quantity determines which version is shown"
    end

    # Email templates
    if key_parts.any? { |part| %w[mailer email subject].include?(part) }
      contexts << "Used in email templates - consider email-appropriate language and formatting"
    end

    # API responses
    if key_parts.any? { |part| %w[api error success status].include?(part) }
      contexts << "Part of API responses - should be clear and concise for programmatic use"
    end

    # Accessibility
    if key_parts.any? { |part| %w[label alt title aria].include?(part) }
      contexts << "Used for accessibility - must be descriptive for screen readers"
    end

    # SEO/Meta
    if key_parts.any? { |part| %w[meta title description].include?(part) }
      contexts << "Used for SEO metadata - affects search engine visibility"
    end

    # Character limits based on context
    if key_parts.any? { |part| %w[title meta].include?(part) }
      contexts << "Should be concise - typically under 60 characters for optimal display"
    elsif key_parts.any? { |part| %w[button btn].include?(part) }
      contexts << "Should be brief - button text should be short and action-oriented"
    end

    contexts << "Standard web interface text - no special formatting requirements" if contexts.empty?

    contexts.join(". ")
  end

  def generate_translation_notes(_key, key_parts, english_text)
    notes = []

    # Brand name preservation
    notes << "Keep 'Exercism' as the brand name - do not translate" if english_text&.include?('Exercism')

    # Programming terminology
    programming_terms = %w[Ruby Python JavaScript CLI API Git GitHub]
    used_terms = programming_terms.select { |term| english_text&.include?(term) }
    notes << "Keep programming terminology unchanged: #{used_terms.join(', ')}" if used_terms.any?

    # Tone and formality
    if key_parts.any? { |part| %w[welcome intro onboarding].include?(part) }
      notes << "Maintain a welcoming, encouraging tone appropriate for learners"
    elsif key_parts.any? { |part| %w[error warning].include?(part) }
      notes << "Use clear, helpful language that guides users toward solutions"
    elsif key_parts.any? { |part| %w[button action].include?(part) }
      notes << "Use action-oriented, imperative language"
    end

    # Cultural adaptation
    notes << "Consider culturally appropriate alternatives for collective terms" if english_text&.match(/\b(folks|guys|team)\b/)

    # Technical precision
    if key_parts.any? { |part| %w[exercise track solution iteration].include?(part) }
      notes << "Maintain consistency with established educational/programming terminology in your language"
    end

    notes.empty? ? nil : notes.join(". ")
  end
end

# Run the enhancement
enhancer = I18nDescriptionEnhancer.new
enhancer.enhance_descriptions
