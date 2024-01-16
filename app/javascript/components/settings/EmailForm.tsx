import React, { useState, useCallback } from 'react'
import { Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { InputWithValidation } from './inputs/InputWithValidation'
import { createMaxLengthAttributes } from './useInvalidField'

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
      <h2>Change your email</h2>
      <hr className="c-divider --small" />
      <div className="field">
        <label htmlFor="user_email" className="label">
          Your email address
        </label>
        <InputWithValidation
          type="email"
          id="user_email"
          value={state.email}
          onChange={(e) => setState({ ...state, email: e.target.value })}
          required
          {...createMaxLengthAttributes('Email', 255)}
        />
      </div>
      <div className="field">
        <label htmlFor="user_sudo_password" className="label">
          Confirm your password
        </label>
        <input
          type="password"
          id="user_sudo_password"
          value={state.password}
          onChange={(e) => setState({ ...state, password: e.target.value })}
          required
        />
        <p className="info">
          You can change your email using the form above. We will send you a new
          confirmation email for you to accept.
        </p>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Change email
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
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      We&apos;ve sent a confirmation email to {email}
    </div>
  )
}
