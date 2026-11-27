import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import GitHubSyncerForm, {
  GitHubSyncerFormProps,
} from '@/components/settings/github-syncer/GitHubSyncerForm'

const props: GitHubSyncerFormProps = {
  links: {
    connectToGithub: '',
    linkGithub: '',
    settings: '/settings/github_syncer',
    syncTrack: '',
    syncEverything: '',
  },
  isUserConnected: true,
  isUserInsider: false,
  isGithubLinked: true,
  githubUsername: 'gh-user',
  syncer: {
    enabled: true,
    repoFullName: 'gh-user/solutions',
    syncOnIterationCreation: true,
    syncExerciseFiles: true,
    commitAsUser: true,
    processingMethod: 'pull_request',
    mainBranchName: 'main',
    commitMessageTemplate: '',
    pathTemplate: '',
  },
  tracks: [],
  defaultPathTemplate: '',
  defaultCommitMessageTemplate: '',
}

test('a user who is not an Insider can save the commit author', async () => {
  const fetchMock = jest.fn().mockResolvedValue({ ok: true })
  global.fetch = fetchMock

  render(<GitHubSyncerForm {...props} />)

  expect(
    screen.getByText(/count towards your GitHub contribution graph/)
  ).toBeInTheDocument()
  expect(
    screen.getByText(/your real email address stays private/)
  ).toBeInTheDocument()

  await userEvent.click(screen.getByRole('button', { name: 'The syncer bot' }))
  const section = screen
    .getByRole('heading', { name: 'Commit author' })
    .closest('section') as HTMLElement
  await userEvent.click(
    section.querySelector('.btn-primary') as HTMLButtonElement
  )

  await waitFor(() => expect(fetchMock).toHaveBeenCalled())
  expect(JSON.parse(fetchMock.mock.calls[0][1].body)).toEqual({
    github_solution_syncer: { commit_as_user: false },
  })
})
