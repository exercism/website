import React from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useMutation } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { FormButton } from '../../common/FormButton'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { useConfirmation } from '../../../hooks/use-confirmation'
import { Track } from '../../types'

type UserTrack = {
  links: {
    self: string
  }
}

const DEFAULT_ERROR = new Error('Unable to reset track')

export const ResetTrackModal = ({
  endpoint,
  track,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  track: Track
}): JSX.Element => {
  const confirmation = `reset ${track.slug}`
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<UserTrack | undefined>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
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

  const { attempt, setAttempt, isAttemptPass } = useConfirmation(confirmation)

  return (
    <Modal className="m-reset-track m-destructive" onClose={onClose} {...props}>
      <form>
        <div className="info">
          <h2>You’re about to reset all your {track.title} progress.</h2>
          <p>
            <strong>Please read this carefully before continuing.</strong>
          </p>
          <p>
            This is <em>irreversible</em> and will mean you’ll lose everything
            you’ve done on this track.
          </p>
          <hr />
          <p>
            <strong>By resetting this track, you will lose access to:</strong>
          </p>
          <ul>
            <li>All solutions you have submitted in {track.title}</li>
            <li>All mentoring you have received in {track.title}</li>
            <li>
              Lose any reputation you have earned for publishing solutions in{' '}
              {track.title}
            </li>
          </ul>
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
            onClick={() => onClose()}
            status={status}
            type="button"
            className="btn-default btn-m"
          >
            Cancel
          </FormButton>
          <FormButton
            onClick={() => mutation()}
            status={status}
            disabled={!isAttemptPass}
            className="btn-primary btn-m"
          >
            Reset track
          </FormButton>
        </div>
        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
