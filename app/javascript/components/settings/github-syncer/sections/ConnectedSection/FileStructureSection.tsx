// i18n-key-prefix: fileStructureSection
// i18n-namespace: components/settings/github-syncer/sections/ConnectedSection
import React, { useCallback, useState } from 'react'
import { flushSync } from 'react-dom'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function FileStructureSection() {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection'
  )
  const { links, isUserInsider, syncer, defaultPathTemplate } =
    React.useContext(GitHubSyncerContext)

  const [pathTemplate, setPathTemplate] = useState<string>(
    syncer?.pathTemplate || defaultPathTemplate
  )
  const [isRevertPathTemplateModalOpen, setIsRevertPathTemplateModalOpen] =
    useState(false)

  const [isTemplateInvalid, setIsTemplateInvalid] = useState<boolean>(false)

  const handleSaveChanges = useCallback(
    (template: string) => {
      if (!isUserInsider) return

      if (!isPathTemplateValid(template)) {
        setIsTemplateInvalid(true)
        return
      } else {
        setIsTemplateInvalid(false)
      }

      fetchWithParams({
        url: links.settings,
        params: {
          path_template: template,
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
    },
    [isUserInsider, links.settings]
  )

  const handleRevertPathTemplate = useCallback(() => {
    flushSync(() => {
      setPathTemplate(defaultPathTemplate)
    })
    handleSaveChanges(defaultPathTemplate)
    setIsRevertPathTemplateModalOpen(false)
  }, [defaultPathTemplate, handleSaveChanges])

  return (
    <section className={isUserInsider ? '' : 'disabled'}>
      <SectionHeader title={t('fileStructureSection.fileStructure')} />
      <p className="text-18 leading-150 mb-16">
        {t('fileStructureSection.configureFolderStructure')}
      </p>
      <p className="text-16 leading-150 mb-12">
        {t('fileStructureSection.placeholderValues')}
      </p>

      <ul className="text-16 leading-150 mb-16">
        <li>
          <Trans
            ns="components/settings/github-syncer/sections/ConnectedSection"
            i18nKey="fileStructureSection.trackSlug"
            components={{ code: <code /> }}
          />
        </li>
        <li>
          <Trans
            ns="components/settings/github-syncer/sections/ConnectedSection"
            i18nKey="fileStructureSection.trackTitle"
            components={{ code: <code /> }}
          />
        </li>
        <li>
          <Trans
            ns="components/settings/github-syncer/sections/ConnectedSection"
            i18nKey="fileStructureSection.exerciseSlug"
            components={{ code: <code /> }}
          />
        </li>
        <li>
          <Trans
            ns="components/settings/github-syncer/sections/ConnectedSection"
            i18nKey="fileStructureSection.exerciseTitle"
            components={{ code: <code /> }}
          />
        </li>
        <li>
          <Trans
            ns="components/settings/github-syncer/sections/ConnectedSection"
            i18nKey="fileStructureSection.iterationIdx"
            components={{ code: <code /> }}
          />
        </li>
      </ul>
      <input
        type="text"
        value={pathTemplate}
        style={{ color: !isUserInsider ? '#aaa' : '' }}
        className={assembleClassNames(
          'font-mono font-semibold text-16 leading-140 border border-1 w-full mb-16',
          isTemplateInvalid && '!border-orange'
        )}
        onChange={(e) => {
          setPathTemplate(e.target.value)
          setIsTemplateInvalid(false)
        }}
      />
      <p className="text-16 leading-150 mb-12">
        <Trans
          i18nKey="fileStructureSection.note1YourPath"
          ns="components/settings/github-syncer/sections/ConnectedSection"
          components={{
            code: <code />,
            strong: <strong className="font-medium" />,
          }}
        />
      </p>
      <p className="text-16 leading-150 mb-16">
        <Trans
          i18nKey="fileStructureSection.note2Iteration"
          ns="components/settings/github-syncer/sections/ConnectedSection"
          components={{
            code: <code />,
            strong: <strong className="font-medium" />,
          }}
        />
      </p>

      {isTemplateInvalid && (
        <div className="text-orange font-semibold mb-16">
          {t('fileStructureSection.pathTemplateMustInclude')}
        </div>
      )}

      <div className="flex gap-8">
        <button
          disabled={!isUserInsider}
          className="btn btn-primary"
          onClick={() => handleSaveChanges(pathTemplate)}
        >
          {t('fileStructureSection.saveChanges')}
        </button>

        <button
          disabled={!isUserInsider || pathTemplate === defaultPathTemplate}
          className="btn btn-secondary"
          onClick={() => setIsRevertPathTemplateModalOpen(true)}
        >
          {t('fileStructureSection.revertToDefault')}
        </button>
      </div>
      <ConfirmationModal
        title={t('fileStructureSection.areYouSureWantRevert')}
        confirmLabel={t('fileStructureSection.revert')}
        declineLabel={t('fileStructureSection.cancel')}
        onConfirm={handleRevertPathTemplate}
        open={isRevertPathTemplateModalOpen}
        onClose={() => setIsRevertPathTemplateModalOpen(false)}
      />
    </section>
  )
}

function isPathTemplateValid(pathTemplate: string): boolean {
  const hasTrackPlaceholder =
    pathTemplate.includes('$track_slug') ||
    pathTemplate.includes('$track_title')

  const hasExercisePlaceholder =
    pathTemplate.includes('$exercise_slug') ||
    pathTemplate.includes('$exercise_title')

  return hasTrackPlaceholder && hasExercisePlaceholder
}
