import React, { useState, useCallback } from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { FauxInputWithValidation } from './inputs/FauxInputWithValidation'
import { createMaxLengthAttributes } from './useInvalidField'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  update: string
}

type RequestBody = {
  user: {
    handle: string
    sudo_password: string
  }
}

const DEFAULT_ERROR = new Error('Unable to change handle')

export default function HandleForm({
  defaultHandle,
  links,
}: {
  defaultHandle: string
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation()
  const [state, setState] = useState({ handle: defaultHandle, password: '' })
  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user: {
        handle: state.handle,
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
      <h2>{t('handleForm.changeYourHandle')}</h2>
      <hr className="c-divider --small" />
      <div className="field">
        <label htmlFor="user_handle" className="label">
          {t('handleForm.yourHandle')}
        </label>
        <FauxInputWithValidation
          icon="at-symbol"
          id="user_handle"
          value={state.handle}
          onChange={(e) => setState({ ...state, handle: e.target.value })}
          required
          {...createMaxLengthAttributes('Handle', 190, t)}
        />
      </div>
      <div className="field">
        <label htmlFor="user_sudo_password_handle" className="label">
          {t('handleForm.confirmYourPassword')}
        </label>
        <input
          type="password"
          id="user_sudo_password_handle"
          value={state.password}
          onChange={(e) => setState({ ...state, password: e.target.value })}
          required
        />
        <p className="info">{t('handleForm.handleChangeRecommendation')}</p>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          {t('handleForm.changeHandle')}
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
      {t('handleForm.success')}
    </div>
  )
}
