# View Components

> **Related Documentation**: See [`commands.md`](./commands.md) for the Mandate pattern used in view components and [`react-components.md`](./react-components.md) for client-side component patterns.

View components are self-contained server-side components that encapsulate logic and rendering. They provide a way to create reusable UI elements that combine Ruby logic with template rendering, following the component pattern for better organization and testability.

## Architecture

View components are located in `app/helpers/view_components/` and inherit from the base `ViewComponent` class:

```ruby
module ViewComponents
  class Bootcamp::ExerciseWidget < ViewComponent
    initialize_with :exercise, solution: nil, user_project: nil, size: nil

    def to_s
      render template: "components/bootcamp/exercise_widget", locals: {
        exercise:,
        project: exercise.project,
        solution:,
        status:,
        size:
      }
    end

    private
    def status
      s = user_project&.exercise_status(exercise, solution) ||
          (::Bootcamp::Exercise::AvailableForUser.(exercise, current_user) ? :available : :locked)

      s = 'completed-bonus' if s == :completed && (solution.passed_bonus_tests? || !exercise.has_bonus_tasks?)
      s
    end

    memoize
    def solution
      @solution || current_user.bootcamp_solutions.find_by(exercise:)
    end

    memoize
    def user_project
      @user_project || ::Bootcamp::UserProject.for(current_user, exercise.project)
    end
  end
end
```

## Base ViewComponent Class

The base class provides access to view helpers and context:

```ruby
module ViewComponents
  class ViewComponent
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    delegate :user_signed_in?, :current_user,
      :render, :safe_join, :raw,
      :tag, :link_to, :external_link_to, :button_to, :image_tag, :image_url,
      :time_ago_in_words, :pluralize, :number_with_delimiter,
      :graphical_icon, :icon, :track_icon, :exercise_icon, :avatar,
      :capture_haml,
      :showing_modal?, :showing_modal!,
      :javascript_include_tag, :request,
      :session, :controller,
      to: :view_context

    def render_in(context, *_args)
      @view_context = context
      to_s
    end

    private
    attr_reader :view_context
  end
end
```

## Key Patterns

**Mandate Integration**: Uses `initialize_with` for parameter definition:
```ruby
initialize_with :primary_param, optional_param: nil, flag: false
```

**Template Rendering**: The `to_s` method defines what gets rendered:
```ruby
def to_s
  render template: "components/namespace/component_name", locals: {
    # Pass data to the template
  }
end
```

**Memoization**: Use for expensive computations or database queries:
```ruby
memoize
def expensive_calculation
  # Complex logic here
end
```

**View Context Access**: All standard Rails helpers are available:
- `current_user` - Authentication state
- `link_to`, `image_tag` - HTML helpers  
- `render` - Nested template rendering
- `icon`, `avatar` - Custom Exercism helpers

## Usage in Views

View components are rendered using the standard Rails `render` method:

```haml
= render ViewComponents::Bootcamp::ExerciseWidget.new(exercise, solution: current_solution, size: :small)
```

Or in ERB:
```erb
<%= render ViewComponents::Bootcamp::ExerciseWidget.new(exercise, solution: current_solution, size: :small) %>
```

## Template Organization

Component templates are stored in `app/views/components/` following the namespace:

- Component: `ViewComponents::Bootcamp::ExerciseWidget`
- Template: `app/views/components/bootcamp/exercise_widget.html.haml`

## Benefits

**Encapsulation**: Logic and presentation are contained within the component
**Reusability**: Components can be used across multiple views and contexts
**Testability**: Components can be tested in isolation with specific parameters
**Organization**: Complex UI logic is separated from controller and view concerns

## Testing View Components

View components are tested in `test/helpers/view_components/`:

```ruby
class ViewComponents::Bootcamp::ExerciseWidgetTest < ActionView::TestCase
  test "renders exercise widget with solution" do
    exercise = create :bootcamp_exercise
    solution = create :bootcamp_solution, exercise: exercise
    
    component = ViewComponents::Bootcamp::ExerciseWidget.new(exercise, solution: solution)
    rendered = render component
    
    assert_includes rendered, exercise.title
    assert_includes rendered, "completed"
  end
end
```

## Common Patterns

**Status computation**: Components often calculate display state:
```ruby
private
def status
  return :locked unless available?
  return :completed if solution&.completed?
  :in_progress
end
```

**Conditional rendering**: Use helper methods for complex display logic:
```ruby
private
def show_bonus_indicator?
  solution&.passed_bonus_tests? && exercise.has_bonus_tasks?
end
```

**Parameter defaults**: Handle optional parameters gracefully:
```ruby
initialize_with :exercise, solution: nil, size: :medium, show_details: true
```