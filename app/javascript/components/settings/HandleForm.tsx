import React, { useState, useCallback } from 'react'
import { GraphicalIcon, FormButton, Icon } from '../common'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'

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

export const HandleForm = ({
  defaultHandle,
  links,
}: {
  defaultHandle: string
  links: Links
}): JSX.Element => {
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
      <h2>Change your handle</h2>
      <hr className="c-divider --small" />
      <div className="field">
        <label htmlFor="user_handle" className="label">
          Your handle
        </label>
        <label className="c-faux-input">
          <GraphicalIcon icon="at-symbol" />
          <input
            type="text"
            id="user_handle"
            value={state.handle}
            onChange={(e) => setState({ ...state, handle: e.target.value })}
            required
          />
        </label>
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
          We recommend only changing your handle in rare circumstances as public
          solution links will break, and it is confusing for mentors.
        </p>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Change handle
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
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your handle has been changed
    </div>
  )
}
