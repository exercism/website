import React, { useState, useCallback } from 'react'
import { FormButton, Icon } from '../common'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'

type Links = {
  update: string
}

type RequestBody = {
  user: {
    theme_preference: string
  }
}

const DEFAULT_ERROR = new Error('Unable to update pronouns')

export const ThemePreferenceForm = ({
  defaultThemePreference,
  links,
}: {
  defaultThemePreference: string
  links: Links
}): JSX.Element => {
  const [theme, setTheme] = useState<string>(defaultThemePreference || '')

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user: { theme_preference: theme } },
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
      <h2>Theme</h2>
      <div className="instructions"></div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Update theme preference
        </FormButton>
        <FormMessage
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
          SuccessMessage={() => <SuccessMessage theme={theme} />}
        />
      </div>
    </form>
  )
}

const SuccessMessage = ({ theme }: { theme: string }) => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your theme has been set to {theme}
    </div>
  )
}
