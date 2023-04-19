import React, { useState, useCallback } from 'react'
import { useSettingsMutation } from './useSettingsMutation'
import { FormButton, Icon } from '../common'
import { FormMessage } from './FormMessage'

type Links = {
  update: string
}

type RequestBody = {
  user: {
    api_key: string
    sudo_password: string
  }
}

const DEFAULT_ERROR = new Error('Unable to update ChatGPT API key')

export const ChatGptForm = ({
  currentApiKey,
  links,
}: {
  currentApiKey: string
  links: Links
}): JSX.Element => {
  const [state, setState] = useState({ apiKey: currentApiKey, password: '' })
  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user: {
        api_key: state.apiKey,
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
      <h2>ChatGPT</h2>
      <div className="field">
        <label htmlFor="api_key" className="label">
          Paste your ChatGPT secret key here
        </label>
        <input
          type="text"
          id="api_key"
          value={state.apiKey}
          onChange={(e) => setState({ ...state, apiKey: e.target.value })}
          required
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
        <p className="info">Only available to Insiders</p>
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Update ChatGPT API key
        </FormButton>
        <FormMessage
          status={status}
          defaultError={DEFAULT_ERROR}
          error={error}
          SuccessMessage={() => <SuccessMessage apiKey={state.apiKey} />}
        />
      </div>
    </form>
  )
}

const SuccessMessage = ({ apiKey }: { apiKey: string }) => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your new API key is: {apiKey}
    </div>
  )
}
