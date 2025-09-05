# Assemblers

> **Related Documentation**: See [`commands.md`](./commands.md) for the Mandate pattern used in assemblers and [`serializers.md`](./serializers.md) for the underlying serialization pattern.

Assemblers provide a common interface for searching and serializing data that can be used to write initial data to a page and then guarantee the same results via API calls. They combine data retrieval logic with serialization, ensuring consistency between server-side rendered pages and client-side API responses.

## Architecture

Assemblers are located in `app/assemblers/` and inherit from the base `Assembler` class:

```ruby
class AssembleExerciseWidget < Assembler
  include Mandate

  def initialize(exercise, user_track,
                 with_tooltip:, render_blurb:, render_track:, recommended:, skinny:, solution: nil)
    super()

    @exercise = exercise
    @user_track = user_track
    @solution = solution
    @with_tooltip = with_tooltip
    @render_blurb = render_blurb
    @render_track = render_track
    @recommended = recommended
    @skinny = skinny
  end

  def call
    {
      exercise: SerializeExercise.(exercise, user_track:, recommended:),
      track: render_track ? SerializeTrack.(exercise.track, user_track) : nil,
      solution: solution ? SerializeSolution.(solution, user_track:) : nil,
      links: links,
      render_blurb:,
      skinny:
    }
  end

  private
  attr_reader :exercise, :user_track, :solution, :with_tooltip, :render_blurb, :render_track,
    :recommended, :skinny

  def links
    {
      tooltip: with_tooltip ? Exercism::Routes.tooltip_track_exercise_path(exercise.track, exercise) : nil
    }.compact
  end
end
```

## Base Assembler Class

The `Assembler` base class provides common functionality:

```ruby
class Assembler
  protected

  def sideload?(item)
    return false unless params[:sideload]

    params[:sideload].include?(item.to_s)
  end
end
```

## Key Responsibilities

**Data Aggregation**: Assemblers combine multiple serializers and data sources:

- Primary entity serialization (e.g., exercise)
- Related entity serialization (e.g., track, solution)
- Additional metadata and links
- Configuration flags for rendering options

**Consistency Guarantee**: The same assembler used for:

1. **Initial page render**: Server-side data injection into HTML
2. **API responses**: Client-side data fetching and updates

## Usage Patterns

**In Controllers**: Assemblers are called using the `.()` syntax:

```ruby
class API::ExercisesController < API::BaseController
  def widget_data
    render json:
             AssembleExerciseWidget.call(
               exercise,
               current_user_track,
               with_tooltip: true,
               render_blurb: params[:show_blurb],
               render_track: params[:include_track],
               recommended: false,
               skinny: params[:compact]
             )
  end
end
```

**In Views**: For initial page data:

```ruby
# In a view file
<div data-react-data="<%= AssembleExerciseWidget.(exercise, user_track, options).to_json %>">
```

## Common Assembler Patterns

**Configuration via parameters**: Use keyword arguments for rendering options:

```ruby
def initialize(entity, user_context, with_tooltip:, render_detail:, skinny: false)
```

**Conditional serialization**: Include related data based on flags:

```ruby
def call
  {
    primary_data: SerializePrimary.call(entity),
    related_data: render_detail ? SerializeRelated.call(entity.related) : nil,
    metadata: build_metadata
  }.compact
end
```

**Links and navigation**: Provide URLs for client-side navigation:

```ruby
def links
  {
    api_endpoint: api_path, tooltip: with_tooltip? ? tooltip_path : nil
  }.compact
end
```

## Benefits

- **Consistency**: Same data format for SSR and API responses
- **Performance**: Can optimize queries for initial page loads vs. API calls
- **Maintainability**: Single source of truth for complex data assemblies
- **Flexibility**: Configurable output based on context and requirements
