import React, { useContext } from 'react'
import Modal, { ModalProps } from '@/components/modals/Modal'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { GraphicalIcon, Icon } from '@/components/common'

type ConfirmationModalProps = Omit<ModalProps, 'className'> & {
  confirmButtonClass?: string
}

export function ConnectModal({
  onClose,
  ...props
}: ConfirmationModalProps): JSX.Element {
  const { links } = useContext(GitHubSyncerContext)

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
        <h3 className="text-[24px]! mb-4!">Connect a Repository</h3>
        <p className="text-18! leading-140 mb-16 text-balance text-center">
          Before continuing, please ensure you have either created a new GitHub
          repository, or that you have an existing one ready to sync.
        </p>
        <p className="text-18! leading-140 mb-16 text-balance text-center">
          On the next screen you will be asked to give permission to that
          repository. Please ensure you{' '}
          <strong>select only one repository</strong> (sadly, GitHub doesn't
          give us a way to enforce that!)
        </p>
      </div>

      <div className="flex gap-8 items-center">
        <a
          className="btn btn-l btn-primary w-fit"
          href={links?.connectToGithub}
        >
          Connect a GitHub repository
        </a>
        <button className="btn btn-default btn-l" onClick={onClose}>
          Cancel
        </button>
      </div>
    </Modal>
  )
}
