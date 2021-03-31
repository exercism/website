import React, { useCallback } from 'react'
import { useMutation } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { FormButton } from '../../common'
import { FetchingBoundary } from '../../FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to start exercise')

export const StartExerciseButton = ({
  endpoint,
  className = '',
}: {
  endpoint: string
  className?: string
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<{
    links: { exercise: string }
  }>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (data) => {
        window.location.replace(data.links.exercise)
      },
    }
  )

  const handleClick = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <React.Fragment>
      <FormButton status={status} onClick={handleClick} className={className}>
        Start in editor
      </FormButton>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      />
    </React.Fragment>
  )
}
