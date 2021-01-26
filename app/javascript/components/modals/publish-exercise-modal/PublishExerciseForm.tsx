import React, { useCallback, useState } from 'react'
import { useMutation } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { ExerciseCompletion } from '../CompleteExerciseModal'

export const PublishExerciseForm = ({
  endpoint,
  onSuccess,
}: {
  endpoint: string
  onSuccess: (data: ExerciseCompletion) => void
}): JSX.Element => {
  const [toPublish, setToPublish] = useState(true)
  const isMountedRef = useIsMounted()
  const [mutation] = useMutation<ExerciseCompletion>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ publish: toPublish }),
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
      <label>
        <div className="c-radio-button">
          <input
            type="radio"
            name="share"
            checked={toPublish}
            onChange={() => setToPublish(true)}
          />
          <div className="radio" />
        </div>
        <div className="label">
          Yes, I'd like to share my solution with the community.
        </div>
      </label>
      <label>
        <div className="c-radio-button">
          <input
            type="radio"
            name="share"
            checked={!toPublish}
            onChange={() => setToPublish(false)}
          />
          <div className="radio" />
        </div>
        <div className="label">
          No, I just want to mark the exercise as complete.
        </div>
      </label>
      <button className="confirm-button btn-large-cta">Confirm</button>
    </form>
  )
}
