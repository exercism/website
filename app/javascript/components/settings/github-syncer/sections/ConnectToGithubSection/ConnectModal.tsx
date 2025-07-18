import React, { useContext } from 'react'
import Modal, { ModalProps } from '@/components/modals/Modal'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { Icon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type ConfirmationModalProps = Omit<ModalProps, 'className'> & {
  confirmButtonClass?: string
}

export function ConnectModal({
  onClose,
  ...props
}: ConfirmationModalProps): JSX.Element {
  const { links } = useContext(GitHubSyncerContext)
  const { t } = useAppTranslation('settings/github-syncer')

  return (
    <Modal className="m-generic-confirmation" onClose={onClose} {...props}>
      <div className="flex flex-col items-center max-w-[540px] mx-auto pb-12">
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
        <h3 className="!text-[24px] !mb-4">{t('connect_modal.heading')}</h3>
        <p className="!text-18 leading-140 mb-16 text-balance text-center">
          {t('connect_modal.intro1')}
        </p>
        <p
          className="!text-18 leading-140 mb-16 text-balance text-center"
          dangerouslySetInnerHTML={{ __html: t('connect_modal.intro2') }}
        />
      </div>

      <div className="flex gap-8 items-center">
        <a
          className="btn btn-l btn-primary w-fit"
          href={links?.connectToGithub}
        >
          {t('connect_modal.connect_button')}
        </a>
        <button className="btn btn-default btn-l" onClick={onClose}>
          {t('connect_modal.cancel_button')}
        </button>
      </div>
    </Modal>
  )
}
