import React, { useState, useCallback } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/mentor/FinishMentorDiscussionModal'
import { ModalProps } from '../../modals/Modal'
import { MentorSessionDiscussion as Discussion } from '../../types'

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
        className="btn-keyboard-shortcut finish-button"
        onClick={() => {
          setOpen(true)
        }}
      >
        <div className="--hint">End discussion</div>
        <div className="--kb">F3</div>
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
