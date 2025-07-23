import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { SectionHeader } from '../../common/SectionHeader'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function SyncBehaviourSection() {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection/SyncBehaviourSection.tsx'
  )
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
          toast.success(t('syncBehaviour.savedChangesSuccessfully'))
        } else {
          await handleJsonErrorResponse(
            response,
            t('syncBehaviour.failedToSaveChanges')
          )
        }
      })
      .catch((error) => {
        console.error('Error:', error)
        toast.error(t('syncBehaviour.somethingWentWrongWhileSaving'))
      })
  }, [shouldSyncOnIterationCreation, links.settings, t])

  return (
    <section className={isUserInsider ? '' : 'disabled'}>
      <div className="flex gap-48 items-start">
        <div>
          <SectionHeader title={t('syncBehaviour.syncBehaviour')} />
          <p className="text-16 leading-150 mb-16">
            <Trans
              ns="components/settings/github-syncer/sections/ConnectedSection/SyncBehaviourSection.tsx"
              i18nKey="syncBehaviour.syncingOptionDescription"
              components={{
                strong: <strong />,
              }}
            />
          </p>
          <div className="flex gap-8 mb-16">
            <button
              onClick={() => setShouldSyncOnInterationCreation(true)}
              className={assembleClassNames(
                'toggle-button',
                shouldSyncOnIterationCreation ? 'selected' : ''
              )}
            >
              {t('syncBehaviour.automatic')}
            </button>
            <button
              onClick={() => setShouldSyncOnInterationCreation(false)}
              className={assembleClassNames(
                'toggle-button',
                !shouldSyncOnIterationCreation ? 'selected' : ''
              )}
            >
              {t('syncBehaviour.manual')}
            </button>
          </div>

          <button
            disabled={!isUserInsider}
            className="btn btn-primary"
            onClick={handleSaveChanges}
          >
            {t('syncBehaviour.saveChanges')}
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
