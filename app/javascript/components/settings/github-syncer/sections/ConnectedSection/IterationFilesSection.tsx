import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { SectionHeader } from '../../common/SectionHeader'
import { GraphicalIcon } from '@/components/common'

export function IterationFilesSection() {
  const { links, isUserInsider, syncer } = React.useContext(GitHubSyncerContext)
  const [shouldSyncExerciseFiles, setShouldSyncExerciseFiles] =
    useState<boolean>(syncer?.syncExerciseFiles ?? true)

  const handleSaveChanges = useCallback(() => {
    if (!isUserInsider) return
    fetchWithParams({
      url: links.settings,
      params: {
        sync_exercise_files: shouldSyncExerciseFiles,
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
  }, [shouldSyncExerciseFiles, links.settings])

  return (
    <section className={isUserInsider ? '' : 'disabled'}>
      <div className="flex gap-48 items-start">
        <div>
          <SectionHeader title="Iteration files" />
          <p className="text-16 leading-150 mb-16">
            When syncing, do you want all the files in the exercise (e.g. your
            solution, the tests, the README, the hints, etc) to be synced to
            GitHub, or only your solution file(s)?
          </p>
          <div className="flex gap-8 mb-16">
            <button
              onClick={() => setShouldSyncExerciseFiles(true)}
              className={assembleClassNames(
                'toggle-button',
                shouldSyncExerciseFiles ? 'selected' : ''
              )}
            >
              The full exercise
            </button>
            <button
              onClick={() => setShouldSyncExerciseFiles(false)}
              className={assembleClassNames(
                'toggle-button',
                !shouldSyncExerciseFiles ? 'selected' : ''
              )}
            >
              Only my solution file(s)
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
          icon="github-syncer-files"
          category="graphics"
          className="w-[200px] opacity-[0.5]"
        />
      </div>
    </section>
  )
}
