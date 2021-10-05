import React, { useState, useCallback } from 'react'
import { useSettingsMutation } from './useSettingsMutation'
import { FormButton, Icon, GraphicalIcon } from '../common'
import { FormMessage } from './FormMessage'
import { CommunicationPreferences } from '../types'

type Links = {
  update: string
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export const CommunicationPreferencesForm = ({
  defaultPreferences,
  links,
}: {
  defaultPreferences: readonly CommunicationPreferences[]
  links: Links
}): JSX.Element => {
  const [preferences, setPreferences] = useState(defaultPreferences)
  const { mutation, status, error } = useSettingsMutation({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      communication_preferences: preferences.reduce<Record<string, boolean>>(
        (data, p) => {
          data[p.key] = p.value

          return data
        },
        {}
      ),
    },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const handlePreferenceChange = useCallback(
    (changedPreference) => {
      return (e: React.ChangeEvent<HTMLInputElement>) => {
        setPreferences(
          preferences.map((p) =>
            p.key === changedPreference.key
              ? { ...changedPreference, value: e.target.checked }
              : p
          )
        )
      }
    },
    [preferences]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2>Mentoring</h2>
      {preferences.map((p) => {
        return (
          <label className="c-checkbox-wrapper" key={p.key}>
            <input
              type="checkbox"
              id="communication_preferences_email_on_mentor_started_discussion_notification"
              checked={p.value}
              onChange={handlePreferenceChange(p)}
            />
            <div className="row">
              <div className="c-checkbox">
                <GraphicalIcon icon="checkmark" />
              </div>
              {p.label}
            </div>
          </label>
        )
      })}
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
