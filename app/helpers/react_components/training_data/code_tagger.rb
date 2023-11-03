module ReactComponents
  module TrainingData
    class CodeTagger < ReactComponent
      def to_s
        super("training-data-code-tagger", {
          track: { slug: 'ruby' },
          files: [
            { filename: "hello_world.rb", code: "Hello World" },
            { filename: "some_lib.foo", code: "URGH" }
          ],
          tags: ["concept:boolean"],
          status: :untagged
        })
      end
    end
  end
end
