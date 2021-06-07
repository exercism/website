import React from 'react'
import { Walkthrough } from '../common'
import { Modal, ModalProps } from './Modal'

export const WalkthroughModal = ({
  html,
  ...props
}: ModalProps & { html: string }): JSX.Element => {
  return (
    <Modal {...props}>
      <Walkthrough html={html} />
    </Modal>
  )
}
