import React from 'react'
import Modal from '@/components/modals/Modal'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { Icon } from '@/components/common'
import { handleSyncEverything } from './ManualSyncSection'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function JustConnectedModal(): JSX.Element {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection'
  )
  const { links } = React.useContext(GitHubSyncerContext)
  const [isModalOpen, setIsModalOpen] = React.useState(false)

  React.useEffect(() => {
    const searchParams = new URLSearchParams(window.location.search)
    if (searchParams.get('connected') === 'true') {
      setIsModalOpen(true)
    }
  }, [])

  const handleRemoveParam = React.useCallback(() => {
    const url = new URL(window.location.href)
    url.searchParams.delete('connected')
    window.history.replaceState({}, '', url.toString())
    setIsModalOpen(false)
  }, [])

  const handleSync = React.useCallback(() => {
    handleSyncEverything({ syncEverythingEndpoint: links.syncEverything })
    handleRemoveParam()
  }, [links.syncEverything])

  const handleCloseModal = React.useCallback(() => {
    handleRemoveParam()
    setIsModalOpen(false)
  }, [])

  return (
    <Modal
      className="m-generic-confirmation"
      onClose={handleCloseModal}
      open={isModalOpen}
    >
      <div className="flex flex-col items-start max-w-[540px] mx-auto pb-1">
        <div className="flex gap-20 items-center mb-8">
          <Icon
            icon="exercism-face"
            category="icons"
            alt="Exercism"
            className="mb-16 h-[64px]"
          />
          <Icon
            icon="sync"
            category="graphics"
            alt="Sync with"
            className="mb-16 h-[64px]"
          />
          <Icon
            icon="external-site-github"
            category="icons"
            alt="Github"
            className="mb-16 h-[64px]"
          />
        </div>
        <h3 className="!text-[24px] !mb-8">
          {t('justConnectedModal.repositoryConnected')}
        </h3>
        <p className="!text-18 leading-140 mb-8">
          {t('justConnectedModal.accountConnected')}
        </p>
        <p className="!text-18 leading-140 mb-12">
          {t('justConnectedModal.happyWithDefaults')}
        </p>
      </div>

      <div className="flex gap-8 items-center">
        <button className="btn btn-l btn-primary w-fit" onClick={handleSync}>
          {t('justConnectedModal.backUpEverythingNow')}
        </button>
        <button className="btn btn-default btn-l" onClick={handleCloseModal}>
          {t('justConnectedModal.backUpLater')}
        </button>
      </div>
    </Modal>
  )
}
