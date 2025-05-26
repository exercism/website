import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'

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
          toast.success(
            isUserActive
              ? 'Paused code sync with GitHub.'
              : 'Resumed code sync with GitHub.'
          )
        } else {
          toast.error(`Failed to change status.`)
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [isUserActive, links.settings])

  const handleDelete = useCallback(() => {
    fetchWithParams({ url: links.settings, method: 'DELETE' })
      .then(async (response) => {
        if (response.ok) {
          toast.success('GitHub sync deleted successfully')
        } else {
          const data = await response.json()
          toast.error(
            `Failed to delete GitHub sync: ${
              data.error.message || 'Unknown error'
            }`
          )
        }
      })
      .catch((error) => {
        console.error('Error:', error)
      })
  }, [links.settings])

  return (
    <section className="danger-zone">
      <h2>Danger Zone</h2>
      <p className="text-16 leading-140 mb-16">
        <strong>This is a dangerous zone.</strong> Be careful.
      </p>

      <p className="text-16 leading-140 mb-8">
        {isUserActive
          ? 'You can pause syncing your solution.'
          : "You are not syncing your stuff with GitHub. Click 'Resume' to start syncing."}
      </p>
      <button
        onClick={() => setActivityChangeConfirmationModalOpen(true)}
        className="btn-m mb-16 btn-warning"
      >
        {isUserActive ? 'Pause' : 'Resume'}
      </button>

      <p className="text-16 leading-140 mb-8">
        You can delete your stuff forever.
      </p>
      <button
        onClick={() => setDeleteConfirmationModalOpen(true)}
        className="btn-m btn-alert"
      >
        Delete
      </button>
      {/* DELETE CONFIRMATION MODAL */}
      <ConfirmationModal
        title="Are you sure you want to delete your GitHub sync?"
        description="This action probably cannot be undone."
        confirmLabel="Delete"
        confirmButtonClass="btn-alert"
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
