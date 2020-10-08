class Track < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  has_many :concepts, class_name: "Track::Concept", dependent: :destroy
  has_many :exercises, dependent: :destroy

  has_many :concept_exercises # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :practice_exercises # rubocop:disable Rails/HasManyOrHasOneDependent

  delegate :head_sha, to: :repo, prefix: "git"

  scope :active, -> { where(active: true) }

  def self.for!(param)
    return param if param.is_a?(Track)
    return find_by!(id: param) if param.is_a?(Numeric)

    find_by!(slug: param)
  end

  # TODO: Derive this from the repo
  # rubocop:disable Layout/LineLength
  def about
    '
      C# is a multi-paradigm, statically-typed programming language with object-oriented, declarative, functional, generic, lazy, integrated querying features and type inference.

      __Statically-typed__ means that identifiers have a [type](https://en.wikipedia.org/wiki/Type_system#Static_type_checking) set at compile time--like those in Java, C++ or Haskell--instead of holding data of any type like those in Python, Ruby or JavaScript.

      __Object-oriented__ means that C# provides imperative [class-based objects](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/object-oriented-programming) with features such as single inheritance, interfaces and encapsulation.

      __Declarative__ means programming [what is to be done](https://stackoverflow.com/questions/1784664/what-is-the-difference-between-declarative-and-imperative-programming), as opposed to how it is done (a.k.a imperative programming) (which is an implementation detail which can distract from the domain or business logic).

      __Functional__ means that [functions are first-class data types](https://livebook.manning.com/#!/book/functional-programming-in-c-sharp/chapter-1) that can be passed as arguments to and returned from other functions.
    '.gsub(/      /, '').strip
  end
  # rubocop:enable Layout/LineLength

  def repo
    # TODO: Slug can be removed from this
    # once we're out of the monorepo
    Git::Track.new(repo_url, slug)
  end
end
