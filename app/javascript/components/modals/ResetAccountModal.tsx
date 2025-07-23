import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { useConfirmation } from '@/hooks/use-confirmation'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type APIResponse = {
  links: {
    home: string
  }
}

const DEFAULT_ERROR = new Error('Unable to reset account')

export const ResetAccountModal = ({
  handle,
  endpoint,
  ...props
}: Omit<ModalProps, 'className'> & {
  handle: string
  endpoint: string
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/ResetAccountModal.tsx')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResponse>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ handle: handle }),
      })

      return fetch
    },
    onSuccess: (response) => {
      redirectTo(response.links.home)
    },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const { attempt, setAttempt, isAttemptPass } = useConfirmation(handle)

  return (
    <Modal {...props} className="m-reset-account m-generic-destructive">
      <form data-turbo="false" onSubmit={handleSubmit}>
        <div className="info">
          <h2>{t('youAreAboutToReset')}</h2>
          <p>
            <strong>{t('pleaseReadCarefully')}</strong>
          </p>
          <p>
            <Trans
              ns="components/modals/ResetAccountModal.tsx"
              i18nKey="thisIsIrreversible"
              components={{ em: <em /> }}
            />
          </p>
          <hr />
          <p>
            <Trans
              ns="components/modals/ResetAccountModal.tsx"
              i18nKey="byResettingAccount"
              components={{ strong: <strong /> }}
            />
          </p>
          <ul>
            <li>{t('allSolutionsSubmitted')}</li>
            <li>{t('allMentoringReceived')}</li>
            <li>{t('allMentoringGiven')}</li>
            <li>{t('anyReputationEarned')}</li>
          </ul>
        </div>
        <hr />
        <label htmlFor="confirmation">
          <Trans
            i18nKey="toConfirmWriteHandle"
            ns="components/modals/ResetAccountModal.tsx"
            values={{ handle: handle }}
            components={{ pre: <pre /> }}
          />
        </label>

        <input
          id="confirmation"
          type="text"
          value={attempt}
          onChange={(e) => setAttempt(e.target.value)}
          autoComplete="off"
        />
        <hr />
        <div className="btns">
          <FormButton
            status={status}
            className="btn-default btn-m"
            type="button"
            onClick={props.onClose}
          >
            {t('cancel')}
          </FormButton>
          <FormButton
            type="submit"
            disabled={!isAttemptPass}
            status={status}
            className="btn-primary btn-m"
          >
            {t('resetAccount')}
          </FormButton>
        </div>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage
            error={error}
            defaultError={DEFAULT_ERROR || new Error(t('unableToResetAccount'))}
          />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
