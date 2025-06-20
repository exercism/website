import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { SectionHeader } from '../../common/SectionHeader'
import { GraphicalIcon } from '@/components/common'

const ITERATIONS_TO_SYNC_OPTIONS = [
  { label: 'All Iterations', value: 'all' },
  { label: 'Non-Deleted Iterations', value: 'non_deleted' },
  { label: 'Published Iterations', value: 'published' },
] as const
type IterationsToSyncValue =
  (typeof ITERATIONS_TO_SYNC_OPTIONS)[number]['value']

export function SyncBehaviourSection() {
  const { links, isUserInsider, syncer } = React.useContext(GitHubSyncerContext)

  const [shouldSyncOnIterationCreation, setShouldSyncOnInterationCreation] =
    useState(syncer?.syncOnIterationCreation ?? true)

  const [iterationsToSync, setIterationsToSync] =
    useState<IterationsToSyncValue>('all')

  const handleSaveChanges = useCallback(() => {
    if (!isUserInsider) return
    fetchWithParams({
      url: links.settings,
      params: {
        sync_on_iteration_creation: shouldSyncOnIterationCreation,
      },
    })
      .then(async (response) => {
        if (response.ok) {
          toast.success('Saved changes successfully!')
        } else {
          await handleJsonErrorResponse(response, 'Failed to save changes.')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
        toast.error(
          'Something went wrong while saving changes. Please try again.'
        )
      })
  }, [shouldSyncOnIterationCreation, links.settings])

  return (
    <section className={isUserInsider ? '' : 'disabled'}>
      <div className="flex gap-48 items-start">
        <div>
          <SectionHeader title="Sync behaviour" />
          <p className="text-16 leading-150 mb-16">
            Choose whether syncing should happen automatically when you create a
            new iteration, or manually when you trigger it yourself.{' '}
            <strong>Automatic</strong> keeps your GitHub repo up to date, while{' '}
            <strong>manual</strong> gives you full control.
          </p>
          <div className="flex gap-8 mb-16">
            <button
              onClick={() => setShouldSyncOnInterationCreation(true)}
              className={assembleClassNames(
                'toggle-button',
                shouldSyncOnIterationCreation ? 'selected' : ''
              )}
            >
              Automatic
            </button>
            <button
              onClick={() => setShouldSyncOnInterationCreation(false)}
              className={assembleClassNames(
                'toggle-button',
                !shouldSyncOnIterationCreation ? 'selected' : ''
              )}
            >
              Manual
            </button>
          </div>
          {shouldSyncOnIterationCreation && (
            <>
              <div className="text-16 mb-8 font-medium">
                Which iterations do you want to sync?
              </div>
              <div className="flex gap-8 mb-8">
                {ITERATIONS_TO_SYNC_OPTIONS.map((option) => (
                  <button
                    key={option.value}
                    onClick={() => setIterationsToSync(option.value)}
                    className={assembleClassNames(
                      'toggle-button',
                      iterationsToSync === option.value ? 'selected' : ''
                    )}
                  >
                    {option.label}
                  </button>
                ))}
              </div>
              <p className="text-16 leading-140 mb-16">
                <strong className="font-medium">Note: </strong> This only
                applies to bulk backups. Deleting an iteration will{' '}
                <strong>not</strong> remove it from your repository.
              </p>
            </>
          )}

          <button
            disabled={!isUserInsider}
            className="btn btn-primary"
            onClick={handleSaveChanges}
          >
            Save changes
          </button>
        </div>
        <GraphicalIcon
          icon="github-syncer-automatic"
          category="graphics"
          className="w-[200px] opacity-[0.5]"
        />
      </div>
    </section>
  )
}
