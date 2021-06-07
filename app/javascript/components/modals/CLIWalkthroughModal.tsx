import React from 'react'
import { CLIWalkthrough, GraphicalIcon } from '../common'
import { Modal, ModalProps } from './Modal'

export const CLIWalkthroughModal = ({
  html,
  ...props
}: Omit<ModalProps, 'className'> & { html: string }): JSX.Element => {
  return (
    <Modal {...props} className="m-cli-walkthrough" cover={true}>
      <GraphicalIcon
        icon="wizard-modal"
        category="graphics"
        className="wizard-icon"
      />
      <CLIWalkthrough html={html} />
    </Modal>
  )
}
