import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams } from '../../fetchWithParams'
import { SectionHeader } from '../../common/SectionHeader'

export function IterationFilesSection() {
  const { links, isUserInsider } = React.useContext(GitHubSyncerContext)
  const [shouldSyncExerciseFiles, setShouldSyncExerciseFiles] =
    useState<boolean>(false)

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
  }, [shouldSyncExerciseFiles, links.settings])

  return (
    <section>
      <SectionHeader title="Iteration files" />
      <p className="text-16 leading-140 mb-16">
        Do you want to include just your solution files, or all the files in the
        exercise?
      </p>
      <div className="flex gap-8 mb-16">
        <button
          onClick={() => setShouldSyncExerciseFiles(false)}
          className={assembleClassNames(
            'btn btn-xs border border-1',
            !shouldSyncExerciseFiles
              ? 'bg-[var(--backgroundColorNotificationsUnreadDot)] border-midnightBlue text-backgroundColorA'
              : ''
          )}
        >
          Only solution files
        </button>

        <button
          onClick={() => setShouldSyncExerciseFiles(true)}
          className={assembleClassNames(
            'btn btn-xs border border-1',
            shouldSyncExerciseFiles
              ? 'bg-[var(--backgroundColorNotificationsUnreadDot)] border-midnightBlue text-backgroundColorA'
              : ''
          )}
        >
          All files
        </button>
      </div>

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
