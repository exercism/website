import React, { useCallback, useState } from 'react'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'
import { flushSync } from 'react-dom'

export function CommitMessageTemplateSection() {
  const { links, isUserInsider, syncer, defaultCommitMessageTemplate } =
    React.useContext(GitHubSyncerContext)

  const [commitMessageTemplate, setCommitMessageTemplate] = useState<string>(
    syncer?.commitMessageTemplate || defaultCommitMessageTemplate
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
    <section>
      <SectionHeader title="Commit message template" />
      <p className="text-18 leading-150 mb-16">
        Use this option to determine what your commit and PR messages should
        look like.
      </p>
      <p className="text-16 leading-150 mb-12">
        You can use the following placeholder values, which will be interpolated
        for each commit:
      </p>

      <ul className="text-16 leading-150 mb-16">
        <li>
          <code>$track_slug</code>: The slug of the track (e.g. "csharp").
        </li>
        <li>
          <code>$track_name</code>: The name of the track (e.g. "C#")
        </li>
        <li>
          <code>$exercise_slug</code>: The slug of the exercise (e.g.
          "hello-world")
        </li>
        <li>
          <code>$exercise_name</code>: The name of the exercise (e.g. "Hello
          World")
        </li>
        <li>
          <code>$iteration_idx</code>: The iteration index of the exercise (e.g.
          "1")
        </li>
        <li>
          <code>$sync_object</code> (optional): One of "Iteration", "Solution",
          "Track", or "Everything" depending on what is syncing. For automatic
          syncs, this will be "Iteration".
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
        <strong className="font-medium">Note:</strong> If your commit message
        contains leading or trailing slashes or dashes, these will be stripped.
        If it contains multiple consecutive slashes or dashes, these will be
        reduced to single slashes or dashes.
      </p>

      <div className="flex gap-8">
        <button
          disabled={!isUserInsider}
          className="btn btn-primary"
          onClick={() => handleSaveChanges(commitMessageTemplate)}
        >
          Save changes
        </button>

        <button
          disabled={!isUserInsider}
          className="btn btn-secondary"
          onClick={() => setIsRevertCommitMessageTemplateModalOpen(true)}
        >
          Revert to default
        </button>
      </div>
      <ConfirmationModal
        title="Are you sure you want to revert your commit message template to default?"
        confirmLabel="Revert"
        declineLabel="Cancel"
        onConfirm={handleRevertCommitMessageTemplate}
        open={isRevertCommitMessageTemplateModalOpen}
        onClose={() => setIsRevertCommitMessageTemplateModalOpen(false)}
      />
    </section>
  )
}
