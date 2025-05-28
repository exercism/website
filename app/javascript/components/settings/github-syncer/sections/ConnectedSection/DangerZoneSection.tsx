import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { GraphicalIcon } from '@/components/common'

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
      <div className="flex gap-48 items-start">
        <div>
          <p className="text-16 leading-140 mb-16">
            <strong>This is a dangerous zone.</strong> Be careful.
          </p>

          <p className="text-16 leading-140 mb-8">
            {isUserActive
              ? 'You can pause syncing your solution.'
              : "Your syncer is currently disabled. Click 'Resume' to start syncing."}
          </p>
          <button
            onClick={() => setActivityChangeConfirmationModalOpen(true)}
            className="btn-m mb-16 btn-warning"
          >
            {isUserActive ? 'Pause' : 'Resume'}
          </button>

          <div className="border-t-1 border-borderColor6 my-32" />

          <p className="text-16 leading-140 mb-8">
            Want to disconnect the syncer from your GitHub repository? Use the
            button below.
          </p>
          <p className="text-16 leading-140 mb-8">
            <strong className="font-medium">Note: </strong> This will also
            delete all settings on this page, so please manually save any
            settings you might wish to reuse in the future (e.g. your path
            template).
          </p>
          <button
            onClick={() => setDeleteConfirmationModalOpen(true)}
            className="btn-m btn-alert"
          >
            Disconnect GitHub
          </button>
          {/* DELETE CONFIRMATION MODAL */}
          <ConfirmationModal
            title="Are you sure you want to disconnect your GitHub repository?"
            description="This action cannot be undone."
            confirmLabel="Disconnect Syncer"
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
        </div>
        <GraphicalIcon
          icon="github-syncer-danger"
          category="graphics"
          className="w-[200px] opacity-[0.5]"
        />
      </div>
    </section>
  )
}
