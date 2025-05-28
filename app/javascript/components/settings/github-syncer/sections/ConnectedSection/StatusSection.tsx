import React, { useCallback, useState } from 'react'
import toast from 'react-hot-toast'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { fetchWithParams } from '../../fetchWithParams'
import { ConfirmationModal } from '../../common/ConfirmationModal'

export function StatusSection() {
  const { links, isSyncingEnabled, setIsSyncingEnabled, syncer } =
    React.useContext(GitHubSyncerContext)

  const color = isSyncingEnabled ? 'var(--successColor)' : '#F69605'
  const status = isSyncingEnabled ? 'Active' : 'Paused'

  const [
    isActivityChangeConfirmationModalOpen,
    setActivityChangeConfirmationModalOpen,
  ] = useState(false)
  const handleActivityChangeConfirmationModalClose = useCallback(() => {
    setActivityChangeConfirmationModalOpen(false)
  }, [])

  const handleEnableSyncing = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: { enabled: true },
    })
      .then((response) => {
        if (response.ok) {
          toast.success('Resumed code sync with GitHub.')
          setActivityChangeConfirmationModalOpen(false)
          setIsSyncingEnabled(true)
        } else {
          toast.error(`Failed to change status.`)
          setActivityChangeConfirmationModalOpen(false)
        }
      })
      .catch((error) => {
        console.error('Error:', error)
        setActivityChangeConfirmationModalOpen(false)
      })
  }, [links.settings])

  return (
    <section style={{ borderColor: color }} className="border-2">
      <h2>
        Status: <span style={{ color }}>{status}</span>
      </h2>
      <p className="text-18 leading-140">
        Your GitHub syncer is linked to <code>{syncer?.repoFullName}</code>.
      </p>

      {!isSyncingEnabled && (
        <>
          <button
            onClick={() => setActivityChangeConfirmationModalOpen(true)}
            className="btn-m mt-16 btn-primary"
          >
            Enable Syncer
          </button>
          <ConfirmationModal
            title="Are you sure you want to resume syncing solutions with GitHub?"
            confirmLabel="Resume"
            declineLabel="Cancel"
            onConfirm={handleEnableSyncing}
            open={isActivityChangeConfirmationModalOpen}
            onClose={handleActivityChangeConfirmationModalClose}
          />
        </>
      )}
    </section>
  )
}
