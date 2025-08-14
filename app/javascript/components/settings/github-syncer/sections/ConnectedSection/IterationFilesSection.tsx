import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { SectionHeader } from '../../common/SectionHeader'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function IterationFilesSection() {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection'
  )
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
          <SectionHeader title={t('iterationFilesSection.iterationFiles')} />
          <p className="text-16 leading-150 mb-16">
            {t('iterationFilesSection.whenSyncing')}
          </p>
          <div className="flex gap-8 mb-16">
            <button
              onClick={() => setShouldSyncExerciseFiles(true)}
              className={assembleClassNames(
                'toggle-button',
                shouldSyncExerciseFiles ? 'selected' : ''
              )}
            >
              {t('iterationFilesSection.theFullExercise')}
            </button>
            <button
              onClick={() => setShouldSyncExerciseFiles(false)}
              className={assembleClassNames(
                'toggle-button',
                !shouldSyncExerciseFiles ? 'selected' : ''
              )}
            >
              {t('iterationFilesSection.onlyMySolutionFiles')}
            </button>
          </div>

          <button
            disabled={!isUserInsider}
            className="btn btn-primary"
            onClick={handleSaveChanges}
          >
            {t('iterationFilesSection.saveChanges')}
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
