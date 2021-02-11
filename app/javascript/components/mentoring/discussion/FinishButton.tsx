import React, { useState, useCallback } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/FinishMentorDiscussionModal'
import { ModalProps } from '../../modals/Modal'
import { Discussion } from '../Solution'

export const FinishButton = ({
  endpoint,
  modalProps,
  onSuccess,
}: {
  endpoint: string
  modalProps?: ModalProps
  onSuccess: (discussion: Discussion) => void
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  const handleSuccess = useCallback(
    (discussion) => {
      onSuccess(discussion)
      setOpen(false)
    },
    [onSuccess]
  )

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
        onSuccess={handleSuccess}
        {...modalProps}
      />
    </React.Fragment>
  )
}
