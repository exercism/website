import React, { useCallback, useState } from 'react'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { SectionHeader } from '../../common/SectionHeader'

const DEFAULT = ''
export function CommitMessageTemplateSection() {
  const { links, isUserInsider } = React.useContext(GitHubSyncerContext)

  const [commitMessageTemplate, setCommitMessageTemplate] = useState<string>('')

  const [
    isRevertCommitMessageTemplateModalOpen,
    setIsRevertCommitMessageTemplateModalOpen,
  ] = useState(false)

  const handleSaveChanges = useCallback(() => {
    if (!isUserInsider) return
    fetchWithParams({
      url: links.settings,
      params: {
        commit_message_template: commitMessageTemplate,
      },
    })
      .then((response) => {
        if (response.ok) {
          console.log('Commit message template was updated successfully')
        } else {
          console.error('Failed to save changes')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [commitMessageTemplate, links.settings, isUserInsider])

  const handleRevertCommitMessageTemplate = useCallback(() => {
    setCommitMessageTemplate(DEFAULT)
    handleSaveChanges()
    setIsRevertCommitMessageTemplateModalOpen(false)
  }, [handleSaveChanges])

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
          <code>$track_slug</code> (mandatory): The slug of the track (e.g.
          "csharp").
        </li>
        <li>
          <code>$track_name</code> (mandatory): The name of the track (e.g.
          "C#")
        </li>
        <li>
          <code>$exercise_slug</code> (mandatory): The slug of the exercise
          (e.g. "hello-world")
        </li>
        <li>
          <code>$exercise_name</code> (mandatory): The name of the exercise
          (e.g. "Hello World")
        </li>
        <li>
          <code>$iteration_idx</code> (optional): The iteration index of the
          exercise (e.g. "1")
        </li>
        <li>
          <code>$sync_object</code> (optional): One of "Iteration", "Solution",
          "Track", or "Everything" depending on what is syncing. For automatic
          syncs, this will be "Iteration".
        </li>
      </ul>
      <input
        type="text"
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
          onClick={handleSaveChanges}
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
