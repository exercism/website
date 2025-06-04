import React, { useContext } from 'react'
import Modal, { ModalProps } from '@/components/modals/Modal'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'

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
      <h3>Hello</h3>
      <div className="flex gap-8 items-center">
        <a
          className="btn btn-l btn-primary w-fit"
          href={links?.connectToGithub}
        >
          Connect a GitHub repository
        </a>
        <button className="btn btn-default" onClick={onClose}>
          Cancel
        </button>
      </div>
    </Modal>
  )
}
