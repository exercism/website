import React, { useState, useCallback } from 'react'
import { FormButton } from '@/components/common/FormButton'
import { ProminentLink, Icon } from '@/components/common'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'

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
      <h2>API / CLI Token</h2>
      <div className="label">Your authentication token is:</div>
      <CopyToClipboardButton textToCopy={token} />
      <ProminentLink link={links.info} text="Where do I use this?" />

      <div className="form-footer">
        <FormButton status={status} className="btn-warning btn-m">
          Reset token
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
      Your token has been reset
    </div>
  )
}
