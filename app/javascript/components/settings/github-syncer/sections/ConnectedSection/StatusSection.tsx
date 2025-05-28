import React from 'react'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function StatusSection() {
  const { repoFullName, isUserActive } = React.useContext(GitHubSyncerContext)

  const color = isUserActive ? 'successColor' : 'orange'
  const status = isUserActive ? 'Active' : 'Paused'

  return (
    <section className={assembleClassNames('border-2', `border-${color}`)}>
      <h2>
        Status:{' '}
        <span className={assembleClassNames(`text-${color}`)}>{status}</span>
      </h2>
      <p className="text-18 leading-140 mb-16">
        Your GitHub syncer is linked to <code>{repoFullName}</code>.
      </p>
      {isUserActive ? null : (
        <button className="btn btn-primary">Enable Syncer</button>
      )}
    </section>
  )
}
