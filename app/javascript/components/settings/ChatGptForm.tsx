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
  const [state, setState] = useState(currentApiKey)
  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user: {
        api_key: state,
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
          value={state}
          onChange={(e) => setState(e.target.value)}
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
          SuccessMessage={() => <SuccessMessage />}
        />
      </div>
    </form>
  )
}

const SuccessMessage = (): JSX.Element => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your API key has been updated successfully.
    </div>
  )
}
