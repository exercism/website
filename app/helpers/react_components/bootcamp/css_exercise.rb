module ReactComponents
  class Bootcamp::CSSExercise < ReactComponent
    initialize_with :solution

    def to_s
      super(id, data)
    end

    def id = "bootcamp-css-exercise-page"

    def data
      {
        project: { slug: project.slug },
        exercise: {
          id: exercise.id,
          slug: exercise.slug,
          title: exercise.title,
          introduction_html: exercise.introduction_html,
          css_checks: exercise.config[:checks] || [],
          html_checks: exercise.config[:html_checks] || [],
          config: {
            title: exercise.config[:title],
            description: exercise.config[:description],
            allowed_properties: exercise.config[:allowed_properties],
            disallowed_properties: exercise.config[:disallowed_properties],
            expected:
          }
        },
        solution: {
          uuid: solution.uuid,
          status: solution.status,
          passed_basic_tests: solution.passed_basic_tests?
        },
        test_results: submission&.test_results,
        code: {
          normalize_css:,
          default: {
            css: exercise.default("css")
          },
          stub: {
            css: exercise.stub("css"),
            html: exercise.stub("html")
          },
          should_hide_css_editor: !!exercise.editor_config[:hide_css],
          should_hide_html_editor: !!exercise.editor_config[:hide_html],
          aspect_ratio: exercise.editor_config[:aspect_ratio] || 1,
          code: solution.code,
          stored_at: submission&.created_at,
          readonly_ranges:,
          default_readonly_ranges: exercise.readonly_ranges
        },
        links: {
          post_submission: Exercism::Routes.api_bootcamp_solution_submissions_url(solution_uuid: solution.uuid, only_path: true),
          complete_solution: Exercism::Routes.complete_api_bootcamp_solution_url(solution.uuid, only_path: true),
          projects_index: Exercism::Routes.bootcamp_projects_url(only_path: true),
          dashboard_index: Exercism::Routes.bootcamp_dashboard_url(only_path: true),
          bootcamp_level_url: Exercism::Routes.bootcamp_level_url("idx"),
          custom_fns_dashboard: Exercism::Routes.bootcamp_custom_functions_url
        }
      }
    end

    def expected
      {
        html: exercise.example("html"),
        css: exercise.example("css")
      }
    end

    def readonly_ranges
      return submission.readonly_ranges if submission

      exercise.readonly_ranges
    end

    # rubocop:disable Layout/LineLength
    def normalize_css = "
      * {box-sizing:content-box}
      button,hr,inputp{overflow:visible}progress,sub,sup{vertical-align:baseline}[type=checkbox],[type=radio],legend{box-sizing:border-box;padding:0}html{line-height:1.15;-webkit-text-size-adjust:100%}body, .--jiki-faux-body{margin:0}details,main{display:block}h1{font-size:2em;margin:.67em 0}hr{box-sizing:content-box;height:0}code,kbd,pre,samp{font-family:monospace,monospace;font-size:1em}a{background-color:transparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:bolder}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:ButtonText dotted 1px}fieldset{padding:.35em .75em .625em}legend{color:inherit;display:table;max-width:100%;white-space:normal}textarea{overflow:auto}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}summary{display:list-item}[hidden],template{display:none}
      h1,h2,h3,h4,h5,h6,ul,ol,li,p { margin: 0; padding: 0; }
      body, .--jiki-faux-body { font-size: 14px; line-height: 1.3; -webkit-font-smoothing: antialiased; }
      "
    # rubocop:enable Layout/LineLength

    memoize
    def submission = solution.submissions.last

    delegate :exercise, to: :solution
    delegate :project, to: :exercise
  end
end
