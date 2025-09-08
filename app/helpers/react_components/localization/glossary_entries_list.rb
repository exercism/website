module ReactComponents
  module Localization
    class GlossaryEntriesList < ReactComponent
      initialize_with :glossary_entries, :params

      def to_s
        super(
          "localization-glossary-entries-list",
          {
            glossary_entries:,
            links: {
              localization_glossary_entries_path: Exercism::Routes.localization_glossary_entries_path,
              endpoint: Exercism::Routes.api_localization_glossary_entries_path
            },
            request: glossary_entries_list_request
          }
        )
      end

      private
      def glossary_entries_list_request
        {
          endpoint: Exercism::Routes.api_localization_glossary_entries_path,
          query: glossary_entries_list_params,
          options: {
            initial_data: glossary_entries_list
          }
        }
      end

      memoize
      def glossary_entries_list_params
        {
          criteria: params.fetch(:criteria, ''),
          status: params[:status],
          page: params[:page]
        }.compact
      end

      def glossary_entries_list
        {
          results: glossary_entries_from_tsv,
          meta: {
            current_page: 1,
            total_count: glossary_entries_from_tsv.length,
            total_pages: 1,
            unscoped_total: glossary_entries_from_tsv.length
          }
        }
      end

      def glossary_entries_from_tsv
        tsv_path = Rails.root.join('I18n_GLOSSARY.tsv')
        return [] unless File.exist?(tsv_path)

        entries = []
        File.foreach(tsv_path, chomp: true).with_index do |line, index|
          next if index.zero? # Skip header row

          parts = line.split("\t")
          next if parts.length < 2

          term = parts[0]&.strip
          llm_instructions = parts[1]&.strip

          next if term.blank?

          entries << {
            uuid: SecureRandom.uuid,
            key: term,
            value: llm_instructions || '',
            translations: [
              {
                locale: 'en',
                term: term,
                translation: llm_instructions || '',
                status: 'unchecked',
                llm_instructions: llm_instructions || ''
              }
            ]
          }
        end

        entries
      end
    end
  end
end
