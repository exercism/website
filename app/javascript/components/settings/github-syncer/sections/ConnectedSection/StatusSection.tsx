import React from 'react'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function StatusSection() {
  const { repoFullName, isUserActive } = React.useContext(GitHubSyncerContext)

  const color = isUserActive ? 'successColor' : 'orange'
  const status = isUserActive ? 'enabled' : 'paused'

  return (
    <section className={assembleClassNames('border-2', `border-${color}`)}>
      <h2>
        Status:{' '}
        <span className={assembleClassNames(`text-${color}`)}>{status}</span>
      </h2>
      <p className="text-16 leading-140">
        Your GitHub syncer is{' '}
        <strong className={`text-${color}`}>{status}</strong>. It is linked to{' '}
        <code>{repoFullName || 'random-repo-name'}</code>.
      </p>
    </section>
  )
}
