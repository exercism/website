// i18n-key-prefix: commitAuthorSection
// i18n-namespace: components/settings/github-syncer/sections/ConnectedSection
import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CommitAuthorSection() {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection'
  )
  const { links, syncer } = React.useContext(GitHubSyncerContext)
  const [commitAsUser, setCommitAsUser] = useState(syncer?.commitAsUser ?? true)

  const handleSaveChanges = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: { commit_as_user: commitAsUser },
    })
      .then(async (response) => {
        if (response.ok) {
          toast.success(t('commitAuthorSection.savedChangesSuccessfully'))
        } else {
          await handleJsonErrorResponse(
            response,
            t('commitAuthorSection.failedToSaveChanges')
          )
        }
      })
      .catch((error) => {
        console.error('Error:', error)
        toast.error(t('commitAuthorSection.somethingWentWrongWhileSaving'))
      })
  }, [commitAsUser, links.settings, t])

  return (
    <section>
      <h2 className="!mb-6">{t('commitAuthorSection.commitAuthor')}</h2>
      <p className="text-16 leading-150 mb-16">
        {t('commitAuthorSection.description')}
      </p>
      <div className="flex gap-8 mb-16">
        <button
          onClick={() => setCommitAsUser(true)}
          className={assembleClassNames(
            'toggle-button',
            commitAsUser ? 'selected' : ''
          )}
        >
          {t('commitAuthorSection.me')}
        </button>
        <button
          onClick={() => setCommitAsUser(false)}
          className={assembleClassNames(
            'toggle-button',
            !commitAsUser ? 'selected' : ''
          )}
        >
          {t('commitAuthorSection.theSyncerBot')}
        </button>
      </div>
      <button className="btn btn-primary" onClick={handleSaveChanges}>
        {t('commitAuthorSection.saveChanges')}
      </button>
    </section>
  )
}
