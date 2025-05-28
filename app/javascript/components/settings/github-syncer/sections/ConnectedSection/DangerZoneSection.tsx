import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { GraphicalIcon } from '@/components/common'

export function DangerZoneSection() {
  const { links, syncer } = React.useContext(GitHubSyncerContext)
  const isSyncerEnabled = syncer?.enabled || false

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
    fetchWithParams({
      url: links.settings,
      params: { active: !isSyncerEnabled },
    })
      .then((response) => {
        if (response.ok) {
          toast.success(
            isSyncerEnabled
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
  }, [isSyncerEnabled, links.settings])

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
      <div className="flex gap-48 items-start">
        <div>
          {isSyncerEnabled && (
            <>
              <h2>Pause Syncer</h2>
              <p className="text-16 leading-140 mb-4">
                Want to pause your syncer for a while?
              </p>
              <p className="text-16 leading-140 mb-12">
                Use the button below. You can restart it at any time.
              </p>

              <button
                onClick={() => setActivityChangeConfirmationModalOpen(true)}
                className="btn-m mb-16 btn-warning"
              >
                Pause Syncer
              </button>
              <ConfirmationModal
                title="Are you sure you want to pause syncing solutions with GitHub?"
                confirmLabel="Pause"
                declineLabel="Cancel"
                onConfirm={handleToggleActivity}
                open={isActivityChangeConfirmationModalOpen}
                onClose={handleActivityChangeConfirmationModalClose}
              />
              <div className="border-t-1 border-borderColor6 my-32" />
            </>
          )}

          <h2>Disconnect Syncer</h2>
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
