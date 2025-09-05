# Serializers

> **Related Documentation**: See [`commands.md`](./commands.md) for the Mandate pattern used in serializers and [`API.md`](./API.md) for how serializers are used in API controllers.

Serializers turn ActiveRecord models (or collections) into data structures that are typically returned as JSON. They encapsulate the logic for converting database records into API-friendly formats while avoiding N+1 query problems through strategic eager loading.

## Architecture

Serializers are located in `app/serializers/` and follow the Mandate pattern:

```ruby
class SerializeExercise
  include Mandate

  def initialize(exercise, user_track: nil, recommended: false)
    @exercise = exercise
    @user_track = user_track || UserTrack::External.new(nil)
    @recommended = recommended
  end

  def call
    {
      slug: exercise.slug,
      type: exercise.tutorial? ? 'tutorial' : exercise.git_type,
      title: exercise.title,
      icon_url: exercise.icon_url,
      difficulty: exercise.difficulty_category,
      blurb: exercise.blurb,
      is_external: user_track.external?,
      is_unlocked: unlocked?,
      is_recommended: recommended?,
      links: links
    }
  end

  private

  attr_reader :exercise, :user_track, :recommended

  def unlocked?
    user_track.exercise_unlocked?(exercise)
  end

  def links
    { self: Exercism::Routes.track_exercise_path(exercise.track, exercise) }
  end
end
```

## Naming Conventions

- **Single records**: `SerializeExercise`, `SerializeUser`, `SerializeSolution`
- **Collections**: `SerializeExercises`, `SerializeUsers`, `SerializeSolutions`

## Collection Serializers and N+1 Prevention

Collection serializers are specifically designed to avoid N+1 queries by using eager loading:

```ruby
class SerializeExercises
  include Mandate

  initialize_with :exercises, user_track: nil

  def call
    eager_loaded_exercises.map do |exercise|
      SerializeExercise.(exercise, user_track:, recommended: recommended)
    end
  end

  def eager_loaded_exercises
    exercises.to_active_relation.includes(:track)
  end
end
```

**Key benefits:**

- **Eager loading**: Collections preload associations to prevent N+1 queries
- **Consistent format**: Single and collection serializers produce compatible output
- **Performance**: Database queries are optimized at the collection level

## Usage in Controllers

Serializers are called directly in controllers using the `.()` syntax:

```ruby
class API::ExercisesController < API::BaseController
  def show
    render json:
             SerializeExercise.call(exercise, user_track: current_user_track)
  end

  def index
    render json:
             SerializeExercises.call(exercises, user_track: current_user_track)
  end
end
```

## Common Patterns

**Optional parameters**: Use keyword arguments with defaults for optional context:

```ruby
def initialize(exercise, user_track: nil, recommended: false)
```

**Links section**: Include related resource URLs for API navigation:

```ruby
def links
  {
    self: Exercism::Routes.track_exercise_path(exercise.track, exercise),
    solutions:
      Exercism::Routes.track_exercise_solutions_path(exercise.track, exercise)
  }
end
```

**Context-dependent data**: Adjust output based on user permissions or state:

```ruby
def call # ... base data
  {
    is_unlocked: user_track.exercise_unlocked?(exercise),
    personal_data: user_track.external? ? nil : personal_progress
  }
end
```
