# React Components

> **Related Documentation**: See [`view-components.md`](./view-components.md) for server-side component patterns and [`commands.md`](./commands.md) for the Mandate pattern used in React component helpers.

React components in Exercism are server-side helper classes that render special `<div>` elements with data attributes for client-side React hydration. They bridge server-side Ruby logic with client-side React applications, providing a clean interface for mounting React components with initial data.

## Architecture

React component helpers are located in `app/helpers/react_components/` and inherit from the base `ReactComponent` class:

```ruby
module ReactComponents
  module Common
    class CopyToClipboardButton < ReactComponent
      initialize_with :text_to_copy

      def to_s
        super("common-copy-to-clipboard-button", { text_to_copy: })
      end
    end
  end
end
```

## Base ReactComponent Class

The base class handles the HTML generation for React mounting:

```ruby
module ReactComponents
  class ReactComponent < ViewComponents::ViewComponent
    include ActionView::Helpers::TagHelper

    def to_s(id, data, fitted: false, css_class: nil, wrapper_class_modifier: nil, style: nil, content: nil, persistent: nil)
      css_classes = ["c-react-component"]
      css_classes << "c-react-wrapper-#{id}"
      css_classes << "c-react-wrapper-#{id}-#{wrapper_class_modifier}" if wrapper_class_modifier.present?
      css_classes << '--fitted' if fitted
      css_classes << css_class if css_class

      tag.div(
        content.presence,
        class: css_classes.join(" "),
        style:,
        "data-react-id": id,
        "data-react-data": data.to_json,
        "data-react-hydrate": content.present?,
        "data-persistent": persistent
      )
    end
  end
end
```

## Generated HTML Structure

React components generate HTML like this:

```html
<div
  class="c-react-component c-react-wrapper-common-copy-to-clipboard-button"
  data-react-id="common-copy-to-clipboard-button"
  data-react-data='{"text_to_copy":"Hello World"}'
  data-react-hydrate="false"
></div>
```

## Client-Side Integration

The generated HTML provides mounting points for React:

- **`data-react-id`**: Identifies which React component to mount
- **`data-react-data`**: Initial props/data passed to the React component
- **`data-react-hydrate`**: Whether to hydrate existing content or create new

## Usage in Views

React components are rendered like standard view components:

```haml
= render ReactComponents::Common::CopyToClipboardButton.new("Hello World")
```

```erb
<%= render ReactComponents::Common::CopyToClipboardButton.new("Hello World") %>
```

## Component Examples

**Simple data passing**:

```ruby
module ReactComponents
  module Student
    class ProgressChart < ReactComponent
      initialize_with :user_track, :show_labels

      def to_s
        super("student-progress-chart", {
          completed_exercises: user_track.completed_exercises.count,
          total_exercises: user_track.track.exercises.count,
          show_labels:
        })
      end
    end
  end
end
```

**Complex data assembly**:

```ruby
module ReactComponents
  module Editor
    class CodeEditor < ReactComponent
      initialize_with :solution, :files, :readonly

      def to_s
        super("editor-code-editor", {
          solution_id: solution.id,
          files: files.map { |f| SerializeFile.(f) },
          readonly:,
          autosave_endpoint: api_solution_files_path(solution)
        })
      end
    end
  end
end
```

## Configuration Options

The base `to_s` method accepts several options:

- **`fitted`**: Removes default padding/spacing
- **`css_class`**: Additional CSS classes
- **`wrapper_class_modifier`**: Modifier for wrapper-specific styling
- **`style`**: Inline CSS styles
- **`content`**: Initial HTML content for hydration
- **`persistent`**: Whether component state persists across page loads

## JavaScript Component Registration

Client-side React components must be registered to match the `data-react-id`:

```typescript
// app/javascript/components/common/CopyToClipboardButton.tsx
export default function CopyToClipboardButton({ text_to_copy }: Props) {
  // Component implementation
}

// Component registration
registerReactComponent(
  "common-copy-to-clipboard-button",
  CopyToClipboardButton
);
```

## Common Patterns

**API endpoints**: Pass endpoints for client-side data fetching:

```ruby
def to_s
  super(
    'component-id',
    {
      initial_data: initial_data,
      api_endpoint: api_path,
      update_endpoint: update_path
    }
  )
end
```

**User context**: Include authentication and permissions:

```ruby
def to_s
  super(
    'component-id',
    {
      current_user_id: current_user&.id,
      can_edit: current_user&.can_edit?(resource),
      csrf_token: view_context.form_authenticity_token
    }
  )
end
```

**Serialized data**: Use existing serializers for consistency:

```ruby
def to_s
  super(
    'component-id',
    {
      exercise: SerializeExercise.call(exercise),
      solution: solution ? SerializeSolution.call(solution) : nil
    }
  )
end
```

## Benefits

**Server-side data preparation**: Ruby logic handles data assembly and permissions
**Type safety**: TypeScript interfaces define expected props on the client
**SEO friendly**: Can include initial HTML content for search engines
**Progressive enhancement**: Works with JavaScript disabled when content is provided
**Consistent APIs**: Uses same serializers as API endpoints for data format consistency
