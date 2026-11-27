import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import GitHubSyncerForm, {
  GitHubSyncerFormProps,
} from '@/components/settings/github-syncer/GitHubSyncerForm'

const props: GitHubSyncerFormProps = {
  links: {
    connectToGithub: 'https://github.com/apps/example/installations/new',
    linkGithub: '/users/auth/github?origin=%2Fsettings%2Fgithub_syncer',
    settings: '/settings/github_syncer',
    syncTrack: '',
    syncEverything: '',
  },
  isUserConnected: false,
  isUserInsider: false,
  isGithubLinked: false,
  githubUsername: null,
  syncer: null,
  tracks: [],
  defaultPathTemplate: '',
  defaultCommitMessageTemplate: '',
}

test('asks the user to link GitHub first and disables the backup step', () => {
  render(<GitHubSyncerForm {...props} />)

  expect(
    screen.getByRole('heading', { name: 'Connect your GitHub account' })
  ).toBeInTheDocument()
  expect(
    screen.getByRole('button', { name: 'Link your GitHub account' })
  ).toBeEnabled()
  expect(screen.getByRole('button', { name: 'Setup Backup' })).toBeDisabled()
  expect(
    screen
      .getByRole('button', { name: 'Link your GitHub account' })
      .closest('form')
  ).toHaveAttribute('action', props.links.linkGithub)
})

test('shows the linked username and enables the backup step', () => {
  render(
    <GitHubSyncerForm {...props} isGithubLinked githubUsername="gh-user" />
  )

  expect(screen.getByText('GitHub account linked: gh-user')).toBeInTheDocument()
  expect(
    screen.queryByRole('button', { name: 'Link your GitHub account' })
  ).not.toBeInTheDocument()
  expect(screen.getByRole('button', { name: 'Setup Backup' })).toBeEnabled()
})
