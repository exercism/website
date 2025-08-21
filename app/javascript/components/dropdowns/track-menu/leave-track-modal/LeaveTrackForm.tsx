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
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/dropdowns/track-menu')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<UserTrack | undefined>({
    mutationFn: async () => {
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
          <strong>{t('leaveTrackModal.leaveTrackForm.strongText')}</strong>
        </p>
        <ul>
          <li>
            {t('leaveTrackModal.leaveTrackForm.listItem1', {
              trackTitle: track.title,
            })}
          </li>
          <li>
            {t('leaveTrackModal.leaveTrackForm.listItem2', {
              trackTitle: track.title,
            })}
          </li>
        </ul>
        <p>
          <strong>{t('leaveTrackModal.leaveTrackForm.howeverWeWill')}</strong>
        </p>
        <ul>
          <li>
            {t('leaveTrackModal.leaveTrackForm.listItem3', {
              trackTitle: track.title,
            })}
          </li>
          <li>
            {t('leaveTrackModal.leaveTrackForm.listItem4', {
              trackTitle: track.title,
            })}
          </li>
        </ul>
        <div className="info-box">
          <Icon icon="info-circle" alt="Info" />
          {t('leaveTrackModal.leaveTrackForm.infoBoxText')}
        </div>
      </div>
      <div className="btns">
        <FormButton
          onClick={handleCancel}
          status={status}
          className="btn-default btn-m"
        >
          {t('leaveTrackModal.leaveTrackForm.cancel')}
        </FormButton>
        <FormButton status={status} className="btn-primary btn-m">
          {t('leaveTrackModal.leaveTrackForm.leaveTrack')}
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </form>
  )
}
