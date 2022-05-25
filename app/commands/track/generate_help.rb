class Track
  class GenerateHelp
    include Mandate

    initialize_with :track

    def call
      track_help = Markdown::Render.(track.git.help, :text)
      general_help_intro = I18n.t('exercises.documents.help_check_pages').strip
      general_help = I18n.t('exercises.documents.help_pages', track_title: track.title, track_slug: track.slug).strip

      <<~TEXT.strip
        # Help

        #{track_help}

        #{general_help_intro}

        #{general_help}
      TEXT
    end
  end
end
