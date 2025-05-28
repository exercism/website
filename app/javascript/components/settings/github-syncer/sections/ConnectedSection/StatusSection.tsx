import React, { useCallback, useState } from 'react'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { assembleClassNames } from '@/utils/assemble-classnames'
import toast from 'react-hot-toast'
import { fetchWithParams } from '../../fetchWithParams'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { useLogger } from '@/hooks'

export function StatusSection() {
  const { syncer, links } = React.useContext(GitHubSyncerContext)

  useLogger('syncer', syncer)

  const isSyncerEnabled = syncer?.enabled || false
  const color = isSyncerEnabled ? 'var(--successColor)' : '#F69605'
  const status = isSyncerEnabled ? 'Active' : 'Paused'

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

  return (
    <section style={{ borderColor: color }} className="border-2">
      <h2>
        Status: <span style={{ color }}>{status}</span>
      </h2>
      <p className="text-18 leading-140">
        Your GitHub syncer is linked to <code>{syncer?.repoFullName}</code>.
      </p>

      {!isSyncerEnabled && (
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
            onConfirm={handleToggleActivity}
            open={isActivityChangeConfirmationModalOpen}
            onClose={handleActivityChangeConfirmationModalClose}
          />
        </>
      )}
    </section>
  )
}
