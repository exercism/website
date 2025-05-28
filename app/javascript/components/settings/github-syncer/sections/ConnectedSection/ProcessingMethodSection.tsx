import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { fetchWithParams } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'

export function ProcessingMethodSection() {
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
  }, [selectedProcessingMethod, links.settings, mainBranchName])

  return (
    <section>
      <SectionHeader title="Processing method" />

      <div className="flex gap-48 items-start">
        <div>
          <p className="text-16 leading-150 mb-16">
            Our bot can commit directly to your repository for a fully automated
            setup, or create a pull request which you can approve each time.
            Which method would you prefer?
          </p>
          <div className="flex gap-8 mb-16">
            <button
              onClick={() => setSelectedProcessingMethod('commit')}
              className={assembleClassNames(
                'toggle-button',
                selectedProcessingMethod === 'commit' ? 'selected' : ''
              )}
            >
              Commit directly
            </button>

            <button
              onClick={() => setSelectedProcessingMethod('pull_request')}
              className={assembleClassNames(
                'toggle-button',
                selectedProcessingMethod === 'pull_request' ? 'selected' : ''
              )}
            >
              Create pull request
            </button>
          </div>

          {selectedProcessingMethod === 'commit' && (
            <label className="flex flex-col mb-16">
              <span className="text-16 leading-150 mb-8">
                What is the name of your main branch?
              </span>
              <input
                type="text"
                className="font-mono font-semibold text-16 leading-140 border border-1"
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
            Save changes
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
