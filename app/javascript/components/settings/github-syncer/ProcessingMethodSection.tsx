import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useState, useCallback } from 'react'
import { GitHubSyncerContext } from './GitHubSyncerForm'
import { fetchWithParams } from './fetchWithParams'

export function ProcessingMethodSection() {
  const { links } = React.useContext(GitHubSyncerContext)
  const [selectedProcessingMethod, setSelectedProcessingMethod] = useState<
    'commit' | 'pr'
  >('commit')

  const [mainBranchName, setMainBranchName] = useState<string>('main')

  const handleSaveChanges = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: {
        processing_method: selectedProcessingMethod,
        main_branch_name: mainBranchName,
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Change activity status successfully')
        } else {
          console.error('Failed to change status')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [selectedProcessingMethod, links.settings])

  return (
    <section>
      <h2>Processing method</h2>
      <p className="text-16 leading-140 mb-16">
        Do you want to commit directly or create a pull request?
      </p>
      <div className="flex gap-8 mb-16">
        <button
          onClick={() => setSelectedProcessingMethod('commit')}
          className={assembleClassNames(
            'btn btn-xs border border-1',
            selectedProcessingMethod === 'commit'
              ? 'bg-[var(--backgroundColorIterationCommentsUnread)]  border-midnightBlue text-midnightBlue'
              : ''
          )}
        >
          Commit directly
        </button>

        <button
          onClick={() => setSelectedProcessingMethod('pr')}
          className={assembleClassNames(
            'btn btn-xs border border-1',
            selectedProcessingMethod === 'pr'
              ? 'bg-[var(--backgroundColorIterationCommentsUnread)]  border-midnightBlue text-midnightBlue'
              : ''
          )}
        >
          Create pull request
        </button>
      </div>

      <label className="flex flex-col mb-16">
        <span className="text-16 leading-140 mb-8">
          What is the name of your main branch?
        </span>
        <input
          type="text"
          className="font-mono font-semibold text-16 leading-140 border border-1"
          value={mainBranchName}
          onChange={(e) => setMainBranchName(e.target.value)}
        />
      </label>

      <button className="btn btn-primary" onClick={handleSaveChanges}>
        Save changes
      </button>
    </section>
  )
}
