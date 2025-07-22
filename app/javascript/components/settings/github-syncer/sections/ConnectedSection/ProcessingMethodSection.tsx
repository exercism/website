// i18n-key-prefix: processingMethodSection
// i18n-namespace: components/settings/github-syncer/sections/ConnectedSection
import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function ProcessingMethodSection() {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection'
  )
  const { links, isUserInsider, syncer } = React.useContext(GitHubSyncerContext)
  const [selectedProcessingMethod, setSelectedProcessingMethod] = useState<
    'commit' | 'pull_request'
  >(syncer?.processingMethod || 'commit')

  const [mainBranchName, setMainBranchName] = useState<string>(
    syncer?.mainBranchName || 'main'
  )

  const handleSaveChanges = useCallback(() => {
    if (!isUserInsider) return
    fetchWithParams({
      url: links.settings,
      params: {
        processing_method: selectedProcessingMethod,
        main_branch_name: mainBranchName,
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
  }, [selectedProcessingMethod, links.settings, mainBranchName])

  return (
    <section className={isUserInsider ? '' : 'disabled'}>
      <div className="flex gap-48 items-start">
        <div>
          <SectionHeader
            title={t('processingMethodSection.processingMethod')}
          />
          <p className="text-16 leading-150 mb-16">
            {t('processingMethodSection.ourBot')}
          </p>
          <div className="flex gap-8 mb-16">
            <button
              onClick={() => setSelectedProcessingMethod('commit')}
              className={assembleClassNames(
                'toggle-button',
                selectedProcessingMethod === 'commit' ? 'selected' : ''
              )}
            >
              {t('processingMethodSection.commitDirectly')}
            </button>

            <button
              onClick={() => setSelectedProcessingMethod('pull_request')}
              className={assembleClassNames(
                'toggle-button',
                selectedProcessingMethod === 'pull_request' ? 'selected' : ''
              )}
            >
              {t('processingMethodSection.createPullRequest')}
            </button>
          </div>

          {selectedProcessingMethod === 'commit' && (
            <label className="flex flex-col mb-16">
              <span className="text-16 leading-150 mb-8">
                {t('processingMethodSection.whatIsTheName')}
              </span>
              <input
                type="text"
                className="font-mono font-semibold text-16 leading-140 border border-1"
                style={{ color: !isUserInsider ? '#aaa' : '' }}
                value={mainBranchName}
                onChange={(e) => setMainBranchName(e.target.value)}
              />
            </label>
          )}

          <button
            disabled={!isUserInsider}
            className="btn btn-primary"
            onClick={handleSaveChanges}
          >
            {t('processingMethodSection.saveChange')}
          </button>
        </div>
        <GraphicalIcon
          icon="github-syncer-pr-vs-commit"
          category="graphics"
          className="w-[200px] opacity-[0.5]"
        />
      </div>
    </section>
  )
}
