task stats: 'exercism:stats'

# rubocop:disable Rails/RakeEnvironment
namespace :exercism do
  task :stats do
    require 'rails/code_statistics'
    ::STATS_DIRECTORIES << %w[CSS app/css]
    ::STATS_DIRECTORIES << %w[Commands app/commands]
    ::STATS_DIRECTORIES << %w[Forms app/forms]
    ::STATS_DIRECTORIES << %w[Serializers app/serializers]
    ::STATS_DIRECTORIES << %w[Validators app/validators]
    ::STATS_DIRECTORIES << %w[Lib lib]

    ::STATS_DIRECTORIES << ['Command tests', 'test/commands']
    CodeStatistics::TEST_TYPES << 'Command tests'
    ::STATS_DIRECTORIES << ['Serializer tests', 'test/serializers']
    CodeStatistics::TEST_TYPES << 'Serializer tests'

    class CodeStatistics # rubocop:disable Lint/ConstantDefinitionInBlock
      def calculate_statistics
        pattern = pattern = /^(?!\.).*?\.(rb|js|ts|jsx|tsx|css|rake|haml)$/
        Hash[
          @pairs.map do |pair|
            [pair.first, calculate_directory_statistics(pair.last, pattern)]
          end
        ]
      end
    end
  end
end
# rubocop:enable Rails/RakeEnvironment
