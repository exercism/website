module ReactComponents
  module Impact
    class Chart < ReactComponent
      def to_s
        super(
          "impact-chart",
          {
            milestones: milestones.to_json
          }
        )
      end

      def milestones
        [
          { date: '201309', text: 'Check tooltip radius', emoji: '\u{1f600}' },
          { date: '202006', text: 'See if this emoji is centered', emoji: '\u{1f600}' },
          { date: '202206', text: 'Reached 1M users!!', emoji: '⭐' },
          { date: '201907', text: 'Exercism V2 launched', emoji: '🚀' },
          { date: '201411', text: 'Exercism V1 launched', emoji: '🚀' },
          { date: '201305', text: 'Exercism got launched', emoji: '🤯' }
        ]
      end
    end
  end
end
