import React, { useCallback, useState } from 'react'
import { QueryStatus, useMutation } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { Loading } from '../../common'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { IterationSelector } from '../student/IterationSelector'
import { Iteration } from '../../types'

const DEFAULT_ERROR = new Error('Unable to complete exercise')

const ConfirmButton = ({
  status,
  error,
}: {
  status: QueryStatus
  error: unknown
}) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <button className="confirm-button btn-primary btn-l">Confirm</button>
      )
    case 'loading':
      return <Loading />
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
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<ExerciseCompletion>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({
          publish: toPublish,
          iteration_idx: iterationIdxToPublish,
        }),
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (data) => {
        if (!data) {
          return
        }

        onSuccess(data)
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form onSubmit={handleSubmit}>
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
      <ErrorBoundary>
        <ConfirmButton status={status} error={error} />
      </ErrorBoundary>
    </form>
  )
}
