import React from 'react'
import { GithubSyncerSettings } from '../settings/github-syncer/GitHubSyncerForm'
import { MiniAdvert } from './MiniAdvert'
import { PausedSync } from './PausedSync'
import { ActiveAutomaticSync } from './ActiveAutomaticSync'
import { ActiveManualSync } from './ActiveManualSync'
import { Iteration } from '../types'

// Solutions Page; Add a widget here for "Backup solution". It should have four states:
// No syncer - advert
// Syncer disabled: "Your syncer is currently disabled. Visit your settings (LINK <<) to enable it"
// Syncer enabled + automatic: Say "Your solution will auto-backup to GitHub. If it does not for some reason, please click this button to manually start the backup."
// Syncer enabled + manual: Say "You have automatic syncs disabled. Click to back up your solution".
export function GithubSyncerWidget({
  syncer,
  links,
  iteration,
}: {
  syncer: GithubSyncerSettings | null
  links: {
    githubSyncerSettings: string
    syncIteartion: string
  }
  iteration: Iteration
}): JSX.Element {
  if (!syncer) return <MiniAdvert settingsLink={links.githubSyncerSettings} />
  if (!syncer.enabled)
    return <PausedSync settingsLink={links.githubSyncerSettings} />
  if (syncer.syncOnIterationCreation)
    return (
      <ActiveAutomaticSync
        iteration={iteration}
        syncIterationLink={links.syncIteartion}
      />
    )
  return (
    <ActiveManualSync
      iteration={iteration}
      syncIterationLink={links.syncIteartion}
    />
  )
}

const MOCK_SYNCER: GithubSyncerSettings = {
  enabled: true,
  repoFullName: 'exercism/example-repo',
  syncOnIterationCreation: true,
  syncExerciseFiles: true,
  processingMethod: 'commit',
  mainBranchName: 'unbroken',
  commitMessageTemplate:
    'This is a commit message template for Exercism solutions.',
  pathTemplate: '/path/to/exercise/files',
}
