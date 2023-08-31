import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { FormButton } from '../../../common/FormButton'
import { Icon } from '../../../common'
import { ErrorBoundary, ErrorMessage } from '../../../ErrorBoundary'
import { Track } from '../../../types'
import { UserTrack } from '../LeaveTrackModal'
import { redirectTo } from '../../../../utils/redirect-to'

const DEFAULT_ERROR = new Error('Unable to leave track')

export const LeaveTrackForm = ({
  endpoint,
  track,
  onCancel,
}: {
  endpoint: string
  track: Track
  onCancel: () => void
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<UserTrack | undefined>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
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
          <strong>When you leave the track, you still keep:</strong>
        </p>
        <ul>
          <li>All solutions you have submitted in {track.title}</li>
          <li>All mentoring you have received in {track.title}</li>
        </ul>
        <p>
          <strong>However, we will:</strong>
        </p>
        <ul>
          <li>End all mentoring discussions in {track.title}</li>
          <li>Remove {track.title} from your active tracks list</li>
        </ul>
        <div className="info-box">
          <Icon icon="info-circle" alt="Info" />
          You’re free to join back at anytime and return to where you left off.
        </div>
      </div>
      <div className="btns">
        <FormButton
          onClick={handleCancel}
          status={status}
          className="btn-default btn-m"
        >
          Cancel
        </FormButton>
        <FormButton status={status} className="btn-primary btn-m">
          Leave track
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </form>
  )
}
