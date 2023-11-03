module ReactComponents
  module TrainingData
    class CodeTagger < ReactComponent
      def to_s
        super("training-data-code-tagger", {
          code: {
            "hello_world.rb" => "Hello World",
            "some_lib.foo" => "URGH"
          },
          tags: {
            'Boolean': "concept:boolean"
          },
          status: :untagged
        })
      end
    end
  end
end
