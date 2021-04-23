import React, { useCallback } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { FormButton } from '../../../common'
import { FetchingBoundary } from '../../../FetchingBoundary'

type Links = {
  finish: string
}

const DEFAULT_ERROR = new Error('Unable to submit mentor rating')

export const SatisfiedStep = ({
  links,
  onRequeued,
  onNotRequeued,
  onBack,
}: {
  links: Links
  onRequeued: () => void
  onNotRequeued: () => void
  onBack: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [finish, { status, error }] = useMutation(
    (requeue: boolean) => {
      return sendRequest({
        endpoint: links.finish,
        method: 'PATCH',
        body: JSON.stringify({ rating: 3, requeue: requeue }),
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (data, requeue) => {
        requeue ? onRequeued() : onNotRequeued()
      },
    }
  )
  const handleBack = useCallback(() => {
    onBack()
  }, [onBack])

  return (
    <div>
      <FormButton type="button" onClick={() => finish(true)} status={status}>
        Yes please
      </FormButton>
      <FormButton type="button" onClick={() => finish(false)} status={status}>
        No thanks
      </FormButton>
      <FormButton type="button" onClick={handleBack} status={status}>
        Back
      </FormButton>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      />
    </div>
  )
}
