import React, { useState, useCallback } from 'react'
import { ConfirmationModal } from './ConfirmationModal'
import { GitHubSyncerContext } from './GitHubSyncerForm'
import { fetchWithParams } from './fetchWithParams'

export function DangerZoneSection() {
  const { links, isUserActive } = React.useContext(GitHubSyncerContext)

  const [isDeleteConfirmationModalOpen, setDeleteConfirmationModalOpen] =
    useState(false)
  const handleDeleteConfirmationModalClose = useCallback(() => {
    setDeleteConfirmationModalOpen(false)
  }, [])

  const [
    isActivityChangeConfirmationModalOpen,
    setActivityChangeConfirmationModalOpen,
  ] = useState(false)
  const handleActivityChangeConfirmationModalClose = useCallback(() => {
    setActivityChangeConfirmationModalOpen(false)
  }, [])

  const handleToggleActivity = useCallback(() => {
    fetchWithParams({ url: links.settings, params: { active: !isUserActive } })
      .then((response) => {
        if (response.ok) {
          console.log('Change activity status successfully')
        } else {
          console.error('Failed to change status')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [isUserActive, links.settings])

  const handleDelete = useCallback(() => {
    fetchWithParams({ url: links.settings, method: 'DELETE' })
      .then((response) => {
        if (response.ok) {
          console.log('Deleted successfully')
        } else {
          console.error('Failed to delete')
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [links.settings])

  return (
    <section className="border border-2 border-danger">
      <h2>Danger Zone</h2>
      <p className="text-16 leading-140 mb-16">
        This is a dangerous zone. Be careful.
      </p>

      <p className="text-16 leading-140 mb-8">
        {isUserActive
          ? 'You can pause syncing your solution.'
          : "You are not syncing your stuff with GitHub. Click 'Resume' to start syncing."}
      </p>
      <button
        onClick={() => setActivityChangeConfirmationModalOpen(true)}
        className="btn mb-16"
      >
        {isUserActive ? 'Pause' : 'Resume'}
      </button>

      <p className="text-16 leading-140 mb-8">
        You can delete your stuff forever.
      </p>
      <button
        onClick={() => setDeleteConfirmationModalOpen(true)}
        className="btn"
      >
        Delete
      </button>
      {/* DELETE CONFIRMATION MODAL */}
      <ConfirmationModal
        title="Are you sure you want to delete your GitHub sync?"
        description="This action probably cannot be undone."
        confirmLabel="Delete"
        declineLabel="Cancel"
        onConfirm={handleDelete}
        open={isDeleteConfirmationModalOpen}
        onClose={handleDeleteConfirmationModalClose}
      />

      {/* ACTIVITY CHANGE CONFIRMATION MODAL */}
      <ConfirmationModal
        title={`Are you sure you want to ${
          isUserActive ? 'pause' : 'resume'
        } syncing things with GitHub?`}
        confirmLabel={isUserActive ? 'Pause' : 'Resume'}
        declineLabel="Cancel"
        onConfirm={handleToggleActivity}
        open={isActivityChangeConfirmationModalOpen}
        onClose={handleActivityChangeConfirmationModalClose}
      />
    </section>
  )
}
