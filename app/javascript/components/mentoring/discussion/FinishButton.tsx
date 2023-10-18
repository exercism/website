import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { FinishMentorDiscussionModal } from '@/components/modals/mentor/FinishMentorDiscussionModal'
import { ModalProps } from '@/components/modals/Modal'
import type { MentorDiscussion as Discussion } from '@/components/types'

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
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<Discussion>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch.then((json) => typecheck<Discussion>(json, 'discussion'))
    },
    {
      onSuccess: (discussion) => onSuccess(discussion),
    }
  )

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    setOpen(false)
  }, [status])

  return (
    <React.Fragment>
      <button
        type="button"
        className="btn-xs btn-enhanced finish-button ml-12"
        onClick={() => {
          setOpen(true)
        }}
      >
        <div className="--hint">End discussion</div>
      </button>
      <FinishMentorDiscussionModal
        endpoint={endpoint}
        open={open}
        onFinish={() => mutation()}
        onCancel={handleClose}
        status={status}
        error={error}
        {...modalProps}
      />
    </React.Fragment>
  )
}
