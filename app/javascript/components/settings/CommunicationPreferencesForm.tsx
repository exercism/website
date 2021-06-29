import React, { useState, useCallback } from 'react'
import { useSettingsMutation } from './useSettingsMutation'
import { FormButton, Icon } from '../common'
import { FormMessage } from './FormMessage'
import { CommunicationPreferences } from '../types'

type Links = {
  update: string
}

type RequestBody = {
  communication_preferences: {
    email_on_mentor_started_discussion_notification: boolean
  }
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export const CommunicationPreferencesForm = ({
  defaultPreferences,
  links,
}: {
  defaultPreferences: CommunicationPreferences
  links: Links
}): JSX.Element => {
  const [preferences, setPreferences] = useState<CommunicationPreferences>(
    defaultPreferences
  )
  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      communication_preferences: {
        email_on_mentor_started_discussion_notification:
          preferences.emailOnMentorStartedDiscussionNotification,
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
    <form onSubmit={handleSubmit}>
      <h2>Communication</h2>
      <div className="field">
        <input
          type="checkbox"
          id="communication_preferences_email_on_mentor_started_discussion_notification"
          checked={preferences.emailOnMentorStartedDiscussionNotification}
          onChange={(e) =>
            setPreferences({
              ...preferences,
              emailOnMentorStartedDiscussionNotification: e.target.checked,
            })
          }
        />
        <label
          htmlFor="communication_preferences_email_on_mentor_started_discussion_notification"
          className="label"
        >
          Email me when a mentor starts a discussion
        </label>
      </div>
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
