import React, { useState, useCallback, useEffect } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/mentor/FinishMentorDiscussionModal'
import { ModalProps } from '../../modals/Modal'
import { MentorDiscussion as Discussion } from '../../types'
import Mousetrap from 'mousetrap'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'

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
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<Discussion>(json, 'discussion')
      })
    },
    {
      onSuccess: (discussion) => {
        if (!discussion) {
          return
        }

        onSuccess(discussion)
      },
    }
  )

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    setOpen(false)
  }, [status])

  useEffect(() => {
    Mousetrap.bind('f3', () => {
      open ? mutation() : setOpen(true)
    })

    Mousetrap.bind('f2', handleClose)

    return () => {
      Mousetrap.unbind('f3')
    }
  }, [handleClose, mutation, open])

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
        onFinish={() => mutation()}
        onCancel={handleClose}
        status={status}
        error={error}
        {...modalProps}
      />
    </React.Fragment>
  )
}
