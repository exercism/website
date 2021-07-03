import React, { useState, useCallback, useEffect } from 'react'
import { usePanel } from '../../../hooks/use-panel'
import { DiscussionPostForm } from './DiscussionPostForm'
import { Icon } from '../../common'

export const EditDiscussionPost = ({
  defaultValue,
  endpoint,
  contextId,
}: {
  defaultValue: string
  endpoint: string
  contextId: string
}): JSX.Element => {
  const [value, setValue] = useState(defaultValue)
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel()

  const handleSuccess = useCallback(() => setOpen(false), [setOpen])
  const handleCancel = useCallback(() => setOpen(false), [setOpen])
  const handleChange = useCallback((value) => setValue(value), [setValue])

  useEffect(() => {
    if (open) {
      return
    }

    setValue(defaultValue)
  }, [open, defaultValue])

  return (
    <React.Fragment>
      <button
        {...buttonAttributes}
        type="button"
        className="edit-button"
        onClick={() => setOpen(!open)}
      >
        <Icon icon="edit" alt="Edit" />
      </button>
      {open ? (
        <div {...panelAttributes} className="c-mentor-discussion-post-editor">
          <DiscussionPostForm
            expanded
            onSuccess={handleSuccess}
            onCancel={handleCancel}
            endpoint={endpoint}
            method="PATCH"
            contextId={contextId}
            onChange={handleChange}
            value={value}
          />
        </div>
      ) : null}
    </React.Fragment>
  )
}
