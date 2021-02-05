import React, { useState } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/FinishMentorDiscussionModal'
import { ModalProps } from '../../modals/Modal'

export const FinishButton = ({
  endpoint,
  modalProps,
}: {
  endpoint: string
  modalProps?: ModalProps
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        className="btn-small finish-button"
        onClick={() => {
          setOpen(true)
        }}
      >
        End discussion
      </button>
      <FinishMentorDiscussionModal
        endpoint={endpoint}
        open={open}
        onCancel={() => {
          setOpen(false)
        }}
        {...modalProps}
      />
    </React.Fragment>
  )
}
