import React, { useCallback, useState } from 'react'
import { MutationStatus, useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../utils/send-request'
import { Icon, Loading } from '../../common'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { IterationSelector } from '../student/IterationSelector'
import { Iteration } from '../../types'

const DEFAULT_ERROR = new Error('Unable to complete exercise')

const ConfirmButton = ({
  status,
  error,
}: {
  status: MutationStatus
  error: unknown
}) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <button className="confirm-button btn-primary btn-l">Confirm</button>
      )
    case 'pending':
      return (
        <>
          <div className="confirm-button btn-primary btn-l w-[125px]">
            <Icon icon="spinner" className="animate-spin-slow" alt="loading" />
          </div>
          <Loading />
        </>
      )
    default:
      return null
  }
}

export const PublishSolutionForm = ({
  endpoint,
  iterations,
  onSuccess,
}: {
  endpoint: string
  iterations: readonly Iteration[]
  onSuccess: (data: ExerciseCompletion) => void
}): JSX.Element => {
  const [toPublish, setToPublish] = useState(true)
  const [iterationIdxToPublish, setIterationIdxToPublish] = useState<
    number | null
  >(null)
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<ExerciseCompletion>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({
          publish: toPublish,
          iteration_idx: iterationIdxToPublish,
        }),
      })

      return fetch
    },
    onSuccess: onSuccess,
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <label className="c-radio-wrapper">
        <input
          type="radio"
          name="share"
          checked={toPublish}
          onChange={() => setToPublish(true)}
        />
        <div className="row">
          <div className="c-radio" />
          <div className="label">
            Yes, I'd like to share my solution with the community.
          </div>
        </div>
      </label>
      {toPublish ? (
        <IterationSelector
          iterationIdx={iterationIdxToPublish}
          setIterationIdx={setIterationIdxToPublish}
          iterations={iterations}
        />
      ) : null}
      <label className="c-radio-wrapper">
        <input
          type="radio"
          name="share"
          checked={!toPublish}
          onChange={() => setToPublish(false)}
        />
        <div className="row">
          <div className="c-radio" />
          <div className="label">
            No, I just want to mark the exercise as complete.
          </div>
        </div>
      </label>
      <ErrorBoundary
        FallbackComponent={({ error }: { error: Error }) => {
          return <div className="c-donation-card-error">{error.message}</div>
        }}
      >
        <ConfirmButton status={status} error={error} />
      </ErrorBoundary>
    </form>
  )
}
