module ReactComponents
  module TrainingData
    class CodeTagger < ReactComponent
      def to_s
        super("training-data-code-tagger", {
          code: {
            track: {
              title: 'Ruby',
              iconUrl: 'ruby_icon_url',
              highlightjsLanguage: 'ruby'
            },
            exercise: {
              title: 'Two Fer',
              iconUrl: 'twofer_icon_url'
            },
            files: [
              { filename: "hello_world.rb", content: "Hello World", type: 'readonly' },
              { filename: "some_lib.foo", content: "URGH", type: 'readonly' }
            ]
          },
          tags: ["concept:boolean"],
          links: {
            # TODO: rename these, adjust CodeTagger.types.ts
            confirm_tags_endpoint: '',
            go_back_to_dashboard: ''
          },
          status: :untagged
        })
      end
    end
  end
end
