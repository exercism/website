import React, { useState, useCallback } from 'react'
import { GraphicalIcon } from '../common'
import { useSettingsMutation } from './useSettingsMutation'

type Links = {
  update: string
}

type RequestBody = {
  user: {
    show_on_supporters_page: boolean
  }
}

const DEFAULT_ERROR = new Error('Unable to change setting')

export const ShowOnSupportersPageButton = ({
  defaultValue,
  links,
}: {
  defaultValue: boolean
  links: Links
}): JSX.Element => {
  const [value, setValue] = useState(defaultValue)

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user: { show_on_supporters_page: value } },
  })

  const handleChange = useCallback(
    (e) => {
      setValue(e.target.checked)
      mutation()
    },
    [mutation]
  )

  return (
    <label className="c-checkbox-wrapper ml-auto">
      <input
        type="checkbox"
        id="communication_preferences_email_on_mentor_started_discussion_notification"
        checked={value}
        onChange={handleChange}
      />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        <span className={'text-16 font-medium text-textColor2'}>
          Appear on supporters page?
        </span>
      </div>
    </label>
  )
}
