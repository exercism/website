class PracticeExercise < Exercise
  def self.that_practice(concept)
    joins(:exercise_prerequisites).
      where('exercise_prerequisites.track_concept_id': concept)
  end

  # TODO: Split tracks READMEs out into instructions
  # and then use that via Git"
  def instructions
    %(
Bob is a lackadaisical teenager. In conversation, his responses are very limited.

- Bob answers 'Sure.' if you ask him a question.
- He answers 'Whoa, chill out!' if you yell at him.
- He answers 'Calm down, I know what I'm doing!' if you yell a question at him.
- He says 'Fine. Be that way!' if you address him without actually saying anything.
- He answers 'Whatever.' to anything else.

Bob's conversational partner is a purist when it comes to written communication and
always follows normal rules regarding sentence punctuation in English.
    ).strip
  end
end
