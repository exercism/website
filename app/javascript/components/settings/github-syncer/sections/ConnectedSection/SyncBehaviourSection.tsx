import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams } from '../../fetchWithParams'
import { SectionHeader } from '../../common/SectionHeader'
import { GraphicalIcon } from '@/components/common'

export function SyncBehaviourSection() {
  const { links, isUserInsider, syncer } = React.useContext(GitHubSyncerContext)

  const [shouldSyncOnIterationCreation, setShouldSyncOnInterationCreation] =
    useState(syncer?.syncOnIterationCreation ?? true)

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
  }, [shouldSyncOnIterationCreation, links.settings])

  return (
    <section>
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
