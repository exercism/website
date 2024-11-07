import React, { useState, useCallback, useEffect } from 'react'
import { Icon, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { UserPreference } from '@/components/types'
import { FormMessage } from './FormMessage'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'

type Links = {
  update: string
}

export type UserPreferences = {
  automation: readonly UserPreference[]
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export default function InsiderBenefitsForm({
  defaultPreferences,
  links,
}: {
  defaultPreferences: UserPreferences
  links: Links
}): JSX.Element {
  useEffect(() => {
    console.log('pref', defaultPreferences)
  }, [defaultPreferences])
  const [hideAdverts, setHideAdverts] = useState(false)

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(async () => {
    const { fetch } = sendRequest({
      endpoint: links.update,
      method: 'PATCH',
      body: JSON.stringify({
        user_preferences: { hide_website_adverts: hideAdverts },
      }),
    })

    return fetch
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
      <h2>Insider benefits</h2>
      <label className="c-checkbox-wrapper">
        <input
          type="checkbox"
          checked={hideAdverts}
          onChange={(e) => setHideAdverts(e.target.checked)}
        />
        <div className="row">
          <div className="c-checkbox">
            <GraphicalIcon icon="checkmark" />
          </div>
          Hide website adverts
        </div>
      </label>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Change preferences
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
      Your preferences have been updated
    </div>
  )
}
