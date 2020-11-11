class Track::Concept < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  belongs_to :track

  scope :not_taught, lambda {
    where.not(id: Exercise::TaughtConcept.select(:track_concept_id))
  }

  delegate :about, :links, to: :git

  def blurb
    ParseMarkdown.("
Functions in Elixir can be dispatched dynamically.

All module names are atoms.
All Elixir module names are automatically prefixed with `Elixir.` when compiled.

```elixir
is_atom(Enum)
# => true
Enum == Elixir.Enum
# => true
```

Elixir can resolve a function to be invoked at run-time, using the Module's name to perform a lookup.
The lookup can be done dynamically if the Module's name is bound to a variable.
".strip)
  end

  memoize
  def git
    Git::Concept.new(track.slug, slug, "HEAD")
  end
end
