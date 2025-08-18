// i18n-key-prefix:
// i18n-namespace: components/settings/EmailForm.tsx
import React, { useState, useCallback } from 'react'
import { Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { InputWithValidation } from './inputs/InputWithValidation'
import { createMaxLengthAttributes } from './useInvalidField'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  update: string
}

type RequestBody = {
  user: {
    email: string
    sudo_password: string
  }
}

const DEFAULT_ERROR = new Error('Unable to change email')

export default function EmailForm({
  defaultEmail,
  links,
}: {
  defaultEmail: string
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/settings/EmailForm.tsx')
  const [state, setState] = useState({ email: defaultEmail, password: '' })
  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user: {
        email: state.email,
        sudo_password: state.password,
      },
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
      <h2>{t('changeYourEmail')}</h2>
      <hr className="c-divider --small" />
      <div className="field">
        <label htmlFor="user_email" className="label">
          {t('yourEmailAddress')}
        </label>
        <InputWithValidation
          type="email"
          id="user_email"
          value={state.email}
          onChange={(e) => setState({ ...state, email: e.target.value })}
          required
          {...createMaxLengthAttributes('Email', 255, t)}
        />
      </div>
      <div className="field">
        <label htmlFor="user_sudo_password_email" className="label">
          {t('confirmYourPassword')}
        </label>
        <input
          type="password"
          id="user_sudo_password_email"
          value={state.password}
          onChange={(e) => setState({ ...state, password: e.target.value })}
          required
        />
        <p className="info">{t('info.changeEmailConfirmation')}</p>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          {t('changeEmail')}
        </FormButton>
        <FormMessage
          status={status}
          defaultError={DEFAULT_ERROR}
          error={error}
          SuccessMessage={() => <SuccessMessage email={state.email} />}
        />
      </div>
    </form>
  )
}

const SuccessMessage = ({ email }: { email: string }) => {
  const { t } = useAppTranslation('components/settings/EmailForm.tsx')
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      {t('success.confirmationEmailSent', { email })}
    </div>
  )
}
