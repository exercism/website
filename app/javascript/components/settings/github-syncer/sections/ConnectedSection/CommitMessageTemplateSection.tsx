// i18n-key-prefix: commitMessageTemplateSection
// i18n-namespace: components/settings/github-syncer/sections/ConnectedSection
import React, { useCallback, useState } from 'react'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'
import { flushSync } from 'react-dom'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CommitMessageTemplateSection() {
  const { links, isUserInsider, syncer, defaultCommitMessageTemplate } =
    React.useContext(GitHubSyncerContext)

  const [commitMessageTemplate, setCommitMessageTemplate] = useState<string>(
    syncer?.commitMessageTemplate || defaultCommitMessageTemplate
  )

  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection'
  )

  const [
    isRevertCommitMessageTemplateModalOpen,
    setIsRevertCommitMessageTemplateModalOpen,
  ] = useState(false)

  const handleSaveChanges = useCallback(
    (template: string) => {
      if (!isUserInsider) return
      fetchWithParams({
        url: links.settings,
        params: {
          commit_message_template: template,
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
    [links.settings, isUserInsider]
  )

  const handleRevertCommitMessageTemplate = useCallback(() => {
    flushSync(() => {
      setCommitMessageTemplate(defaultCommitMessageTemplate)
    })
    handleSaveChanges(defaultCommitMessageTemplate)
    setIsRevertCommitMessageTemplateModalOpen(false)
  }, [defaultCommitMessageTemplate, handleSaveChanges])

  return (
    <section className={isUserInsider ? '' : 'disabled'}>
      <SectionHeader title={t('commitMessageTemplateSection.heading')} />
      <p className="text-18 leading-150 mb-16">
        {t('commitMessageTemplateSection.intro')}
      </p>
      <p className="text-16 leading-150 mb-12">
        {t('commitMessageTemplateSection.placeholder_intro')}
      </p>

      <ul className="text-16 leading-150 mb-16">
        <li>
          <code>$track_slug</code>:{' '}
          {t('commitMessageTemplateSection.placeholders.track_slug')}
        </li>
        <li>
          <code>$track_title</code>:{' '}
          {t('commitMessageTemplateSection.placeholders.track_title')}
        </li>
        <li>
          <code>$exercise_slug</code>:{' '}
          {t('commitMessageTemplateSection.placeholders.exercise_slug')}
        </li>
        <li>
          <code>$exercise_title</code>:{' '}
          {t('commitMessageTemplateSection.placeholders.exercise_title')}
        </li>
        <li>
          <code>$iteration_idx</code>:{' '}
          {t('commitMessageTemplateSection.placeholders.iteration_idx')}
        </li>
        <li>
          <code>$sync_object</code>:{' '}
          {t('commitMessageTemplateSection.placeholders.sync_object')}
        </li>
      </ul>

      <input
        type="text"
        value={commitMessageTemplate}
        style={{ color: !isUserInsider ? '#aaa' : '' }}
        className="font-mono font-semibold text-16 leading-140 border border-1 w-full mb-16"
        onChange={(e) => setCommitMessageTemplate(e.target.value)}
      />
      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">
          {t('commitMessageTemplateSection.note.note')}:
        </strong>{' '}
        {t('commitMessageTemplateSection.note.text')}
      </p>

      <div className="flex gap-8">
        <button
          disabled={!isUserInsider}
          className="btn btn-primary"
          onClick={() => handleSaveChanges(commitMessageTemplate)}
        >
          {t('commitMessageTemplateSection.save_button')}
        </button>

        <button
          disabled={
            !isUserInsider ||
            commitMessageTemplate === defaultCommitMessageTemplate
          }
          className="btn btn-secondary"
          onClick={() => setIsRevertCommitMessageTemplateModalOpen(true)}
        >
          {t('commitMessageTemplateSection.revert_button')}
        </button>
      </div>

      <ConfirmationModal
        title={t('commitMessageTemplateSection.confirm_modal.title')}
        confirmLabel={t('commitMessageTemplateSection.confirm_modal.confirm')}
        declineLabel={t('commitMessageTemplateSection.confirm_modal.cancel')}
        onConfirm={handleRevertCommitMessageTemplate}
        open={isRevertCommitMessageTemplateModalOpen}
        onClose={() => setIsRevertCommitMessageTemplateModalOpen(false)}
      />
    </section>
  )
}
