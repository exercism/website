import React, { useState, useCallback } from 'react'
import { useSettingsMutation } from './useSettingsMutation'
import { FormButton, Icon, GraphicalIcon } from '../common'
import { FormMessage } from './FormMessage'

type Links = {
  update: string
}

export type CommentsPreferenceFormProps = {
  links: Links
  currentPreference: boolean
  label: string
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export const CommentsPreferenceForm = ({
  currentPreference,
  links,
  label,
}: CommentsPreferenceFormProps): JSX.Element => {
  const [allowCommentsByDefault, setAllowCommentsByDefault] =
    useState(currentPreference)
  const { mutation, status, error } = useSettingsMutation({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user_preferences: {
        allow_comments_by_default: allowCommentsByDefault,
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

  const handleChange = useCallback((e) => {
    setAllowCommentsByDefault(e.target.checked)
  }, [])

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2>Comments</h2>
      <label className="c-checkbox-wrapper">
        <input
          type="checkbox"
          checked={allowCommentsByDefault}
          onChange={handleChange}
        />
        <div className="row">
          <div className="c-checkbox">
            <GraphicalIcon icon="checkmark" />
          </div>
          {label}
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
