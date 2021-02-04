import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { Discussion } from '../EndSessionModal'
import { typecheck } from '../../../utils/typecheck'

export const AboutToEndSession = ({
  endpoint,
  onSuccess,
  onCancel,
}: {
  endpoint: string
  onSuccess: (discussion: Discussion) => void
  onCancel: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation] = useMutation(
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

  return (
    <div>
      <h1>Are you sure you want to end this session</h1>
      <button type="button" onClick={() => mutation()}>
        End session
      </button>
      <button type="button" onClick={() => onCancel()}>
        Cancel
      </button>
    </div>
  )
}
