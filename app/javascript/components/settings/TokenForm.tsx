import React, { useState, useCallback } from 'react'
import { CopyToClipboardButton, FormButton } from '../common'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { ProminentLink } from '../common'

type Links = {
  reset: string
  info: string
}

const DEFAULT_ERROR = new Error('Unable to reset token')

export const TokenForm = ({
  defaultToken,
  links,
}: {
  defaultToken: string
  links: Links
}): JSX.Element => {
  const [token, setToken] = useState(defaultToken)

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
    <form onSubmit={handleSubmit}>
      <h2>API / CLI Token</h2>
      <div className="label">Your authentication token is:</div>
      <CopyToClipboardButton textToCopy={token} />
      <ProminentLink link={links.info} text="Where do I use this?" />
      <FormButton status={status} className="btn-warning btn-m">
        Reset token
      </FormButton>
      <FormMessage
        status={status}
        defaultError={DEFAULT_ERROR}
        error={error}
        SuccessMessage={SuccessMessage}
      />
    </form>
  )
}

const SuccessMessage = () => {
  return <span>Your auth token has been reset</span>
}
