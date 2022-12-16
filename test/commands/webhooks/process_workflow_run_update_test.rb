require "test_helper"

class Webhooks::ProcessWorkflowRunUpdateTest < ActiveSupport::TestCase
  test "queue handle representer deploy job when deploy workflow conclusion is success" do
    track = create :track, slug: 'fsharp'

    assert_enqueued_with job: MandateJob, args: [Tooling::Representer::HandleDeploy.name, track] do
      Webhooks::ProcessWorkflowRunUpdate.(**representer_deploy_success_args)
    end
  end

  %w[requested in_progress].each do |action|
    test "don't queue handle representer deploy job when deploy workflow action is #{action}" do
      create :track, slug: 'fsharp'

      assert_no_enqueued_jobs do
        Webhooks::ProcessWorkflowRunUpdate.(
          **representer_deploy_success_args.merge({ action: })
        )
      end
    end
  end

  test "don't queue handle representer deploy job when conclusion is failure" do
    create :track, slug: 'fsharp'

    assert_no_enqueued_jobs do
      Webhooks::ProcessWorkflowRunUpdate.(
        **representer_deploy_success_args.merge({ conclusion: 'failure' })
      )
    end
  end

  test "don't queue handle representer deploy job when head_branch is not main" do
    create :track, slug: 'fsharp'

    assert_no_enqueued_jobs do
      Webhooks::ProcessWorkflowRunUpdate.(
        **representer_deploy_success_args.merge({ head_branch: 'fix-logic' })
      )
    end
  end

  test "don't queue handle representer deploy job when docker-build-push-image workflow is not referenced" do
    create :track, slug: 'fsharp'

    assert_no_enqueued_jobs do
      Webhooks::ProcessWorkflowRunUpdate.(
        **representer_deploy_success_args.merge({ referenced_workflows: [] })
      )
    end
  end

  test "don't queue handle representer deploy job when repository is not representer repo" do
    create :track, slug: 'fsharp'

    assert_no_enqueued_jobs do
      Webhooks::ProcessWorkflowRunUpdate.(
        **representer_deploy_success_args.merge({ repo: 'exercism/fsharp-analyzer' })
      )
    end
  end

  private
  def representer_deploy_success_args
    {
      action: 'completed',
      repo: 'exercism/fsharp-representer',
      head_branch: 'main',
      path: '.github/workflows/deploy.yml',
      conclusion: 'success',
      referenced_workflows: ['exercism/github-actions/.github/workflows/docker-build-push-image.yml@main']
    }
  end
end
