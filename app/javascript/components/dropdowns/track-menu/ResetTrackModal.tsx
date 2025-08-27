import React, { useCallback } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { FormButton } from '../../common/FormButton'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { useConfirmation } from '../../../hooks/use-confirmation'
import { Track } from '../../types'
import { redirectTo } from '../../../utils/redirect-to'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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

  const { attempt, setAttempt, isAttemptPass } = useConfirmation(confirmation)

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <Modal
      className="m-reset-track m-generic-destructive"
      onClose={onClose}
      {...props}
    >
      <form onSubmit={handleSubmit}>
        <div className="info">
          <h2>{t('resetTrackModal.heading', { trackTitle: track.title })}</h2>
          <p>{t('resetTrackModal.pleaseReadCarefully')}</p>
          <p>{t('resetTrackModal.irreversible')}</p>
          <hr />
          <p>
            <strong>{t('resetTrackModal.byResettingThisTrack')}</strong>
          </p>
          <ul>
            <li>
              {t('resetTrackModal.listItem1', { trackTitle: track.title })}
            </li>
            <li>
              {t('resetTrackModal.listItem2', { trackTitle: track.title })}
            </li>
            <li>
              {t('resetTrackModal.listItem3', { trackTitle: track.title })}
            </li>
          </ul>
          <p>
            <strong>{t('resetTrackModal.however')}</strong>
          </p>
          <ul>
            <li>{t('resetTrackModal.listItem4')}</li>
            <li>
              {t('resetTrackModal.listItem5', { trackTitle: track.title })}
            </li>
          </ul>
        </div>
        <hr />
        <label htmlFor="confirmation">
          {t('resetTrackModal.confirmationLabel', {
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
            onClick={() => onClose()}
            status={status}
            type="button"
            className="btn-default btn-m"
          >
            {t('resetTrackModal.cancel')}
          </FormButton>
          <FormButton
            status={status}
            disabled={!isAttemptPass}
            className="btn-primary btn-m"
          >
            {t('resetTrackModal.resetTrack')}
          </FormButton>
        </div>
        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
