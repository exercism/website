import React, { useCallback } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { FormButton } from '../../../common/FormButton'
import { ErrorBoundary, ErrorMessage } from '../../../ErrorBoundary'
import { Track } from '../../../types'
import { UserTrack } from '../LeaveTrackModal'

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
  const [mutation, { status, error }] = useMutation<UserTrack | undefined>(
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

        window.location.replace(track.links.self)
      },
    }
  )
  const handleCancel = useCallback(() => {
    onCancel()
  }, [onCancel])

  return (
    <form>
      <div className="info">
        <h2>You’re about to leave the {track.title} track.</h2>
      </div>
      <div className="btns">
        <FormButton
          onClick={handleCancel}
          status={status}
          className="btn-default btn-m"
        >
          Cancel
        </FormButton>
        <FormButton
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          Leave track
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </form>
  )
}
