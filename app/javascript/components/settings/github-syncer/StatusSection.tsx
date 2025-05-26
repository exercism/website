import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useCallback } from 'react'
import { GitHubSyncerContext } from './GitHubSyncerForm'
import { fetchWithParams } from './fetchWithParams'

export function StatusSection() {
  const { repoFullName } = React.useContext(GitHubSyncerContext)

  return (
    <section>
      <h2>Status</h2>
      <p className="text-16 leading-140 mb-16">
        Your GitHub syncer is enabled. It is linked to {repoFullName}.
      </p>
    </section>
  )
}
