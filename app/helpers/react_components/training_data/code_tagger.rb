module ReactComponents
  module TrainingData
    class CodeTagger < ReactComponent
      def to_s
        super("training-data-code-tagger", {
          code: {
            track: {
              title: 'Ruby',
              icon_url: 'ruby_icon_url',
              highlightjs_language: 'ruby'
            },
            exercise: {
              title: 'Two Fer',
              icon_url: 'twofer_icon_url'
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
