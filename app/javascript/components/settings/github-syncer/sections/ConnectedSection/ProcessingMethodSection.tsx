import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { fetchWithParams } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'

export function ProcessingMethodSection() {
  const { links, isUserInsider } = React.useContext(GitHubSyncerContext)
  const [selectedProcessingMethod, setSelectedProcessingMethod] = useState<
    'commit' | 'pr'
  >('commit')

  const [mainBranchName, setMainBranchName] = useState<string>('main')
  const [shouldSyncOnIterationCreation, setShouldSyncOnInterationCreation] =
    useState(false)

  const handleSaveChanges = useCallback(() => {
    if (!isUserInsider) return
    fetchWithParams({
      url: links.settings,
      params: {
        processing_method: selectedProcessingMethod,
        main_branch_name: mainBranchName,
        sync_on_iteration_creation: shouldSyncOnIterationCreation,
      },
    })
      .then(async (response) => {
        if (response.ok) {
          toast.success('Saved changes successfully!')
        } else {
          const data = await response.json()
          toast.error(
            'Failed to save changes: ' + data.error.message || 'Unknown error'
          )
        }
      })
      .catch((error) => {
        console.error('Error:', error)
        toast.error(
          'Something went wrong while saving changes. Please try again.'
        )
      })
  }, [
    selectedProcessingMethod,
    links.settings,
    shouldSyncOnIterationCreation,
    mainBranchName,
  ])

  return (
    <section>
      <SectionHeader title="Processing method" />
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

      {selectedProcessingMethod === 'commit' && (
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
      )}

      <label className="c-checkbox-wrapper mb-16">
        <input
          type="checkbox"
          checked={shouldSyncOnIterationCreation}
          onChange={() => setShouldSyncOnInterationCreation((s) => !s)}
        />
        <div className="row">
          <div className="c-checkbox">
            <GraphicalIcon icon="checkmark" />
          </div>
          Automatically sync to GitHub every time you create an iteration?
        </div>
      </label>

      <button
        disabled={!isUserInsider}
        className="btn btn-primary"
        onClick={handleSaveChanges}
      >
        Save changes
      </button>
    </section>
  )
}
