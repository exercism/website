import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { MentorDiscussion } from '@/components/types'

const DEFAULT_ERROR = new Error('Unable to submit mentor rating')

export const SatisfiedStep = ({
  discussion,
  onRequeued,
  onNotRequeued,
  onBack,
}: {
  discussion: MentorDiscussion
  onRequeued: () => void
  onNotRequeued: () => void
  onBack: () => void
}): JSX.Element => {
  const {
    mutate: finish,
    status,
    error,
  } = useMutation(
    async (requeue: boolean) => {
      const { fetch } = sendRequest({
        endpoint: discussion.links.finish,
        method: 'PATCH',
        body: JSON.stringify({ rating: 3, requeue: requeue }),
      })

      return fetch
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
    <section className="acceptable-decision-step">
      <h2>Sorry that this mentoring wasn&apos;t great.</h2>
      <p className="explanation">
        Would you like to put this exercise back in the queue for another mentor
        to look at?
      </p>

      <div className="form-buttons">
        <FormButton
          type="button"
          onClick={handleBack}
          status={status}
          className="btn-default btn-m"
        >
          Back
        </FormButton>
        <FormButton
          type="button"
          onClick={() => finish(false)}
          status={status}
          className="btn-enhanced btn-m"
        >
          No thanks
        </FormButton>
        <FormButton
          type="button"
          onClick={() => finish(true)}
          status={status}
          className="btn-enhanced btn-m"
        >
          Yes please
        </FormButton>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        />
      </div>
    </section>
  )
}
