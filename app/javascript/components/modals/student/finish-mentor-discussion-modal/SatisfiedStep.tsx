import React from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'

type Links = {
  finish: string
}

export const SatisfiedStep = ({
  links,
  onRequeued,
  onNotRequeued,
}: {
  links: Links
  onRequeued: () => void
  onNotRequeued: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [finish] = useMutation(
    (requeue: boolean) => {
      return sendRequest({
        endpoint: links.finish,
        method: 'POST',
        body: JSON.stringify({ rating: 'satisfied', requeue: requeue }),
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (data, requeue) => {
        requeue ? onRequeued() : onNotRequeued()
      },
    }
  )

  return (
    <div>
      <button type="button" onClick={() => finish(true)}>
        Yes please
      </button>
      <button type="button" onClick={() => finish(false)}>
        No thanks
      </button>
    </div>
  )
}
