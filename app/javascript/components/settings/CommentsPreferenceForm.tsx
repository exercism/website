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
  numPublishedSolutions: string
  numSolutionsWithCommentsEnabled: string
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export const CommentsPreferenceForm = ({
  currentPreference,
  links,
  label,
  numPublishedSolutions,
  numSolutionsWithCommentsEnabled,
}: CommentsPreferenceFormProps): JSX.Element => {
  const [allowCommentsByDefault, setAllowCommentsByDefault] =
    useState(currentPreference)
  const { mutation, status, error } = useSettingsMutation({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user_preferences: {
        allow_comments_on_published_solutions: allowCommentsByDefault,
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

  const handleCommentsPreferenceChange = useCallback((e) => {
    setAllowCommentsByDefault(e.target.checked)
  }, [])

  return (
    <>
      <form data-turbo="false" onSubmit={handleSubmit}>
        <h2 className="!mb-8">Comments</h2>
        <p className="text-p-base mb-12">
          Use these settings to control whether people can post comments on your
          solution or not. These settings change the default behavour for new
          solutions but can be overriden on a per-solution basis.
        </p>
        <label className="c-checkbox-wrapper">
          <input
            type="checkbox"
            checked={allowCommentsByDefault}
            onChange={handleCommentsPreferenceChange}
          />
          <div className="row">
            <div className="c-checkbox">
              <GraphicalIcon icon="checkmark" />
            </div>
            {label}
          </div>
        </label>

        <div className="form-footer !border-0 !pt-0 !mt-0">
          <FormButton status={status} className="btn-primary btn-m">
            Update preference
          </FormButton>
          <FormMessage
            status={status}
            defaultError={DEFAULT_ERROR}
            error={error}
            SuccessMessage={SuccessMessage}
          />
        </div>
      </form>
      <div className="form-footer">
        <div className="flex flex-col items-start">
          <h3 className="text-h5 mb-4">Existing solutions</h3>
          <p className="text-p-base mb-12">
            Currently, people can comment on {numSolutionsWithCommentsEnabled} /{' '}
            {numPublishedSolutions} of your published solutions. You can choose
            to update this in line with your general preference to allow future
            commenting.
          </p>
          <button className="btn-m btn-enhanced">
            Allow comments on all existing solutions
          </button>
        </div>
      </div>
    </>
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
