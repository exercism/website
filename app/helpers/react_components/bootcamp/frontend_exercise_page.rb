module ReactComponents
  class Bootcamp::FrontendExercisePage < ReactComponent
    initialize_with :solution

    def to_s
      super(id, data)
    end

    def id = "bootcamp-frontend-exercise-page"

    def data
      {
        project: { slug: project&.slug },
        exercise: {
          id: exercise&.id,
          slug: exercise&.slug,
          title: exercise&.title,
          introduction_html: exercise&.introduction_html,
          css_checks: config[:checks] || [],
          html_checks: config[:html_checks] || [],
          config: {
            title: config[:title],
            description: config[:description],
            allowed_properties: config[:allowed_properties],
            disallowed_properties: config[:disallowed_properties],
            expected:
          }
        },
        solution: solution_data,
        code: {
          normalize_css:,
          default: {
            css: exercise&.default("css")
          },
          stub: {
            css: ::Bootcamp::Solution::GenerateStub.(exercise, current_user, "css"),
            html: ::Bootcamp::Solution::GenerateStub.(exercise, current_user, "html"),
            js: ::Bootcamp::Solution::GenerateStub.(exercise, current_user, "js")
          },
          aspect_ratio: editor_config[:aspect_ratio] || 1,
          code: solution&.code,
          stored_at: submission&.created_at
        },
        links: solution_links
      }
    end

    def config
      exercise&.config || {}
    end

    def editor_config
      exercise&.editor_config || {}
    end

    def solution_data
      return nil unless solution

      {
        uuid: solution.uuid,
        status: solution.status,
        passed_basic_tests: solution.passed_basic_tests?,
        messages: solution.messages.map do |message|
          {
            author: message.author,
            content: message.content
          }
        end
      }
    end

    def solution_links
      return {} unless solution

      {
        post_submission: Exercism::Routes.api_bootcamp_solution_submissions_url(solution_uuid: solution.uuid, only_path: true),
        complete_solution: Exercism::Routes.complete_api_bootcamp_solution_url(solution.uuid, only_path: true),
        projects_index: Exercism::Routes.bootcamp_projects_url(only_path: true),
        dashboard_index: Exercism::Routes.bootcamp_dashboard_url(only_path: true),
        bootcamp_level_url: Exercism::Routes.bootcamp_level_url("idx"),
        custom_fns_dashboard: Exercism::Routes.bootcamp_custom_functions_url,
        api_bootcamp_solution_chat: Exercism::Routes.api_bootcamp_solution_chat_messages_url(solution_uuid: solution.uuid,
          only_path: true)
      }
    end

    def expected
      return {} unless exercise

      {
        html: exercise.example("html"),
        css: exercise.example("css"),
        js: exercise.example("js")
      }
    end

    def readonly_ranges
      submission&.readonly_ranges || exercise&.readonly_ranges
    end

    # rubocop:disable Layout/LineLength
    def normalize_css = "
      button,hr,input{overflow:visible}progress,sub,sup{vertical-align:baseline}[type=checkbox],[type=radio],legend{box-sizing:border-box;padding:0}html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}details,main{display:block}h1{font-size:2em;margin:.67em 0}hr{box-sizing:content-box;height:0}code,kbd,pre,samp{font-family:monospace,monospace;font-size:1em}a{background-color:transparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:bolder}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:ButtonText dotted 1px}fieldset{padding:.35em .75em .625em}legend{color:inherit;display:table;max-width:100%;white-space:normal}textarea{overflow:auto}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}summary{display:list-item}[hidden],template{display:none}
      h1,h2,h3,h4,h5,h6,ul,ol,li,p { margin: 0; padding: 0; }
      body { font-size: 14px; line-height: 1.3 }
      "
    # rubocop:enable Layout/LineLength

    memoize
    def submission = solution&.submissions&.last

    delegate :exercise, to: :solution, allow_nil: true
    delegate :project, to: :exercise, allow_nil: true
  end
end
