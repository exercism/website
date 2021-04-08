import React from 'react'
import { Modal } from './Modal'

export const TutorialCompletedModal = ({
  open,
}: {
  open: boolean
}): JSX.Element => {
  /* TODO: Add content to this template */
  return (
    <Modal open={open} className="m-completed-exercise" onClose={() => {}}>
      <h1>Tutorial complete</h1>
    </Modal>
  )
}
