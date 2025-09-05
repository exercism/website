// i18n-key-prefix:
// i18n-namespace: components/settings/TokenForm.tsx
import React, { useState, useCallback } from 'react'
import { FormButton } from '@/components/common/FormButton'
import { ProminentLink, Icon } from '@/components/common'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  reset: string
  info: string
}

const DEFAULT_ERROR = new Error('Unable to reset token')

export default function TokenForm({
  defaultToken,
  links,
}: {
  defaultToken: string
  links: Links
}): JSX.Element {
  const [token, setToken] = useState(defaultToken)
  const { t } = useAppTranslation()

  const { mutation, status, error } = useSettingsMutation<
    { token: string },
    { authToken: string }
  >({
    endpoint: links.reset,
    method: 'PATCH',
    body: { token: token },
    onSuccess: (response) => {
      setToken(response.authToken)
    },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2>{t('tokenForm.apiCliToken')}</h2>
      <div className="label">{t('tokenForm.yourAuthenticationTokenIs')}</div>
      <CopyToClipboardButton textToCopy={token} />
      <ProminentLink link={links.info} text={t('tokenForm.whereDoIUseThis')} />

      <div className="form-footer">
        <FormButton status={status} className="btn-warning btn-m">
          {t('tokenForm.resetToken')}
        </FormButton>
        <FormMessage
          status={status}
          defaultError={DEFAULT_ERROR}
          error={error}
          SuccessMessage={SuccessMessage}
        />
      </div>
    </form>
  )
}

const SuccessMessage = () => {
  const { t } = useAppTranslation()
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      {t('tokenForm.yourTokenHasBeenReset')}
    </div>
  )
}
