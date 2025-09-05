import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { FinishMentorDiscussionModal } from '@/components/modals/mentor/FinishMentorDiscussionModal'
import { ModalProps } from '@/components/modals/Modal'
import type { MentorDiscussion as Discussion } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

// i18n-key-prefix: components.mentoring.discussion.finishButton
// i18n-namespace: discussion
export const FinishButton = ({
  endpoint,
  modalProps,
  onSuccess,
}: {
  endpoint: string
  modalProps?: ModalProps
  onSuccess: (discussion: Discussion) => void
}): JSX.Element => {
  const { t } = useAppTranslation()
  const [open, setOpen] = useState(false)
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<Discussion>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch.then((json) => typecheck<Discussion>(json, 'discussion'))
    },
    onSuccess: (discussion) => onSuccess(discussion),
  })

  const handleClose = useCallback(() => {
    if (status === 'pending') {
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
        <Trans
          ns="discussion-batch"
          i18nKey="components.mentoring.discussion.finishButton.endDiscussion"
          components={{ hint: <div className="--hint" /> }}
        />
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
