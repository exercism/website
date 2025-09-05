import React, { useState, useCallback } from 'react'
import { FormButton } from '@/components/common/FormButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  update: string
}

type RequestBody = {
  user: {
    sudo_password: string
    password: string
    password_confirmation: string
  }
}

const DEFAULT_ERROR = new Error('Unable to change password')

export default function PasswordForm({ links }: { links: Links }): JSX.Element {
  const [state, setState] = useState({
    sudoPassword: '',
    password: '',
    passwordConfirmation: '',
  })
  const { t } = useAppTranslation()
  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user: {
        sudo_password: state.sudoPassword,
        password: state.password,
        password_confirmation: state.passwordConfirmation,
      },
    },
    onSuccess: () => window.location.reload(),
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
      <h2>{t('changeYourPassword')}</h2>
      <hr className="c-divider --small" />
      <div className="field">
        <label htmlFor="user_sudo_password" className="label">
          {t('currentPassword')}
        </label>
        <input
          type="password"
          id="user_sudo_password"
          value={state.sudoPassword}
          onChange={(e) => setState({ ...state, sudoPassword: e.target.value })}
          required
        />
      </div>
      <div className="field">
        <label htmlFor="user_password" className="label">
          {t('newPassword')}
        </label>
        <input
          type="password"
          id="user_password"
          value={state.password}
          onChange={(e) => setState({ ...state, password: e.target.value })}
          required
        />
      </div>
      <div className="field">
        <label htmlFor="user_password_confirmation" className="label">
          {t('confirmNewPassword')}
        </label>
        <input
          type="password"
          id="user_password_confirmation"
          value={state.passwordConfirmation}
          onChange={(e) =>
            setState({ ...state, passwordConfirmation: e.target.value })
          }
          required
        />
        <p className="info">
          <strong>{t('warningChangingPassword')}</strong>{' '}
          {t('youCanThenSignBackIn')}
        </p>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          {t('changePassword')}
        </FormButton>
        <FormMessage
          status={status}
          defaultError={DEFAULT_ERROR}
          error={error}
          SuccessMessage={() => null}
        />
      </div>
    </form>
  )
}
