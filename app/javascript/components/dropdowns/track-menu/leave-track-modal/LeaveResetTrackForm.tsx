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
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/dropdowns/track-menu')
  const confirmation = `reset ${track.slug}`
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<UserTrack | undefined>({
    mutationFn: async () => {
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
    onSuccess: (track) => {
      if (!track) {
        return
      }

      redirectTo(track.links.self)
    },
  })
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
          <strong>{t('leaveTrackModal.leaveResetTrackForm.strongText')}</strong>
        </p>
        <ul>
          <li>
            {t('leaveTrackModal.leaveResetTrackForm.listItem1', {
              trackTitle: track.title,
            })}
          </li>
          <li>
            {t('leaveTrackModal.leaveResetTrackForm.listItem2', {
              trackTitle: track.title,
            })}
          </li>
          <li>
            {t('leaveTrackModal.leaveResetTrackForm.listItem3', {
              trackTitle: track.title,
            })}
          </li>
          <li>
            {t('leaveTrackModal.leaveResetTrackForm.listItem4', {
              trackTitle: track.title,
            })}
          </li>
        </ul>

        <p>{t('leaveTrackModal.leaveResetTrackForm.irreversibleText')}</p>
      </div>
      <hr />
      <label htmlFor="confirmation">
        {t('leaveTrackModal.leaveResetTrackForm.confirmationLabel', {
          confirmation,
        })}
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
          {t('leaveTrackModal.leaveResetTrackForm.cancel')}
        </FormButton>
        <FormButton
          status={status}
          disabled={!isAttemptPass}
          className="btn-primary btn-m"
        >
          {t('leaveTrackModal.leaveResetTrackForm.leaveReset')}
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </form>
  )
}
