import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useState, useCallback } from 'react'
import { GitHubSyncerContext } from './GitHubSyncerForm'
import { fetchWithParams } from './fetchWithParams'

export function IterationFilesSection() {
  const { links } = React.useContext(GitHubSyncerContext)
  const [shouldSyncExerciseFiles, setShouldSyncExerciseFiles] =
    useState<boolean>(false)

  const handleSaveChanges = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: {
        sync_exercise_files: shouldSyncExerciseFiles,
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Saved changes successfully')
        } else {
          console.error('Failed to save changes')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [shouldSyncExerciseFiles, links.settings])

  return (
    <section>
      <h2>Iteration files</h2>
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
              ? 'bg-[var(--backgroundColorIterationCommentsUnread)]  border-midnightBlue text-midnightBlue'
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
              ? 'bg-[var(--backgroundColorIterationCommentsUnread)]  border-midnightBlue text-midnightBlue'
              : ''
          )}
        >
          All files
        </button>
      </div>

      <button className="btn btn-primary" onClick={handleSaveChanges}>
        Save changes
      </button>
    </section>
  )
}
