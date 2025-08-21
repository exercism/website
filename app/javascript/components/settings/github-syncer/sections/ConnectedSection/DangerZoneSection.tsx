// i18n-key-prefix: dangerZoneSection
// i18n-namespace: components/settings/github-syncer/sections/ConnectedSection
import React, { useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { ConfirmationModal } from '../../common/ConfirmationModal'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function DangerZoneSection() {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection'
  )
  const { links, isSyncingEnabled, setIsSyncingEnabled, setIsUserConnected } =
    React.useContext(GitHubSyncerContext)

  const [isDeleting, setIsDeleting] = useState(false)

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

  const handlePauseSyncer = useCallback(() => {
    fetchWithParams({
      url: links.settings,
      params: { enabled: false },
    })
      .then((response) => {
        if (response.ok) {
          toast.success('Paused code sync with GitHub.')
          setActivityChangeConfirmationModalOpen(false)
          setIsSyncingEnabled(false)
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

  const handleDelete = useCallback(() => {
    setIsDeleting(true)
    fetchWithParams({ url: links.settings, method: 'DELETE' })
      .then(async (response) => {
        if (response.ok) {
          toast.success('GitHub sync deleted successfully')
          setIsUserConnected(false)
          setDeleteConfirmationModalOpen(false)
        } else {
          handleJsonErrorResponse(response, 'Failed to delete GitHub sync.')
        }
      })
      .catch((error) => {
        toast.error(
          `Oops! We received an unexpected error while deleting the GitHub sync.`
        )
        console.error('Error:', error)
      })
      .finally(() => setIsDeleting(false))
  }, [links.settings])

  return (
    <section className="danger-zone">
      <div className="flex gap-48 items-start">
        <div>
          {isSyncingEnabled && (
            <>
              <h2>{t('dangerZoneSection.pauseSyncer')}</h2>
              <p className="text-16 leading-140 mb-4">
                {t('dangerZoneSection.wantToPause')}
              </p>
              <p className="text-16 leading-140 mb-12">
                {t('dangerZoneSection.useButtonBelow')}
              </p>

              <button
                onClick={() => setActivityChangeConfirmationModalOpen(true)}
                className="btn-m mb-16 btn-warning"
              >
                {t('dangerZoneSection.pauseSyncer')}
              </button>
              <ConfirmationModal
                title="Are you sure you want to pause syncing solutions with GitHub?"
                confirmLabel="Pause"
                declineLabel="Cancel"
                onConfirm={handlePauseSyncer}
                open={isActivityChangeConfirmationModalOpen}
                onClose={handleActivityChangeConfirmationModalClose}
              />
              <div className="border-t-1 border-borderColor6 my-32" />
            </>
          )}

          <h2>{t('dangerZoneSection.disconnectSyncer')}</h2>
          <p className="text-16 leading-140 mb-8">
            {t('dangerZoneSection.wantToDisconnect')}
          </p>
          <p className="text-16 leading-140 mb-8">
            <strong
              className="font-medium"
              dangerouslySetInnerHTML={{
                __html: t('dangerZoneSection.noteWillDeleteSettings'),
              }}
            />
          </p>
          <button
            onClick={() => setDeleteConfirmationModalOpen(true)}
            className="btn-m btn-alert"
          >
            {t('dangerZoneSection.disconnectGithub')}
          </button>
          {/* DELETE CONFIRMATION MODAL */}
          <ConfirmationModal
            title={t('dangerZoneSection.areYouSureDisconnect')}
            description={t('dangerZoneSection.thisActionCannotUndone')}
            confirmLabel={t('dangerZoneSection.disconnectSyncerConfirm')}
            confirmButtonClass="btn-alert"
            isConfirmButtonDisabled={isDeleting}
            declineLabel={t('dangerZoneSection.cancel')}
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
