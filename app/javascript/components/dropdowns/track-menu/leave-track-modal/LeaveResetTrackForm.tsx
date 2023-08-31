import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { FormButton } from '../../../common/FormButton'
import { ErrorBoundary, ErrorMessage } from '../../../ErrorBoundary'
import { Track } from '../../../types'
import { UserTrack } from '../LeaveTrackModal'
import { useConfirmation } from '../../../../hooks/use-confirmation'
import { redirectTo } from '../../../../utils/redirect-to'

const DEFAULT_ERROR = new Error('Unable to leave and reset track')

export const LeaveResetTrackForm = ({
  endpoint,
  track,
  onCancel,
}: {
  endpoint: string
  track: Track
  onCancel: () => void
}): JSX.Element => {
  const confirmation = `reset ${track.slug}`
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<UserTrack | undefined>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ reset: true }),
      })
      return fetch.then((json) => {
        if (!json) {
          return
        }

        return typecheck<UserTrack>(json, 'userTrack')
      })
    },
    {
      onSuccess: (track) => {
        if (!track) {
          return
        }

        redirectTo(track.links.self)
      },
    }
  )
  const handleCancel = useCallback(() => {
    onCancel()
  }, [onCancel])
  const { attempt, setAttempt, isAttemptPass } = useConfirmation(confirmation)

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form onSubmit={handleSubmit}>
      <div className="info">
        <p>
          <strong>By leaving and resetting this track, you will:</strong>
        </p>
        <ul>
          <li>
            Lose access to all solutions you have submitted in {track.title}
          </li>
          <li>
            Lose access to all mentoring you have received in {track.title}
          </li>
          <li>
            Lose any reputation you have earned for publishing solutions in{' '}
            {track.title}
          </li>
          <li>Remove {track.title} from your active tracks list</li>
        </ul>

        <p>
          This is <em>irreversible</em> and will mean you’ll lose everything
          you’ve done on this track.
        </p>
      </div>
      <hr />
      <label htmlFor="confirmation">
        To confirm, write <pre>{confirmation}</pre> in the box below:
      </label>

      <input
        id="confirmation"
        type="text"
        autoComplete="off"
        value={attempt}
        onChange={(e) => setAttempt(e.target.value)}
      />
      <hr />
      <div className="btns">
        <FormButton
          onClick={handleCancel}
          status={status}
          className="btn-default btn-m"
        >
          Cancel
        </FormButton>
        <FormButton
          status={status}
          disabled={!isAttemptPass}
          className="btn-primary btn-m"
        >
          Leave + Reset
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </form>
  )
}
