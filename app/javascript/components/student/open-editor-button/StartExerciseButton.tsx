import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to start exercise')

export const StartExerciseButton = ({
  endpoint,
  className = '',
}: {
  endpoint: string
  className?: string
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<{
    links: { exercise: string }
  }>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: (data) => {
        redirectTo(data.links.exercise)
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
