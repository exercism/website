import React, { useState, useCallback } from 'react'
import { Icon, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { CommunicationPreferences } from '@/components/types'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'

type Links = {
  update: string
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export default function CommunicationPreferencesForm({
  defaultPreferences,
  links,
}: {
  defaultPreferences: CommunicationPreferences
  links: Links
}): JSX.Element {
  const [preferences, setPreferences] = useState(defaultPreferences)
  const { mutation, status, error } = useSettingsMutation({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      communication_preferences: [
        ...preferences.mentoring,
        ...preferences.product,
      ].reduce<Record<string, boolean>>((data, p) => {
        data[p.key] = p.value

        return data
      }, {}),
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
    (changedPreference, key: keyof CommunicationPreferences) => {
      return (e: React.ChangeEvent<HTMLInputElement>) => {
        setPreferences({
          ...preferences,
          [key]: preferences[key].map((p) =>
            p.key === changedPreference.key
              ? { ...changedPreference, value: e.target.checked }
              : p
          ),
        })
      }
    },
    [preferences]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2>Mentoring</h2>
      {preferences.mentoring.map((p) => (
        <label className="c-checkbox-wrapper" key={p.key}>
          <input
            type="checkbox"
            checked={p.value}
            onChange={handlePreferenceChange(p, 'mentoring')}
          />
          <div className="row">
            <div className="c-checkbox">
              <GraphicalIcon icon="checkmark" />
            </div>
            {p.label}
          </div>
        </label>
      ))}
      <h2>Product</h2>
      {preferences.product.map((p) => (
        <label className="c-checkbox-wrapper" key={p.key}>
          <input
            type="checkbox"
            checked={p.value}
            onChange={handlePreferenceChange(p, 'product')}
          />
          <div className="row">
            <div className="c-checkbox">
              <GraphicalIcon icon="checkmark" />
            </div>
            {p.label}
          </div>
        </label>
      ))}
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
