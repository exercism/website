import React, { useContext } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { MentoringRequest } from '../Solution'
import { RequestContext } from '../request/RequestContext'
import { useIsMounted } from 'use-is-mounted'

export const StartMentoringPanel = ({
  request,
}: {
  request: MentoringRequest
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { handleRequestLock } = useContext(RequestContext)
  const [lock] = useMutation<MentoringRequest | undefined>(
    () => {
      return sendRequest({
        endpoint: request.links.lock,
        body: null,
        method: 'PATCH',
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<MentoringRequest>(json, 'request')
      })
    },
    {
      onSuccess: (request) => {
        if (!request) {
          return
        }

        handleRequestLock(request)
      },
    }
  )

  return (
    <section className="comment-section">
      <button type="button" onClick={() => lock()}>
        Start mentoring
      </button>
    </section>
  )
}
