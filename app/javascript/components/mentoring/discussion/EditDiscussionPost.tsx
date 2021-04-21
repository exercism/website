import React, { useCallback } from 'react'
import { usePanel } from '../../../hooks/use-panel'
import { DiscussionPostForm } from './DiscussionPostForm'
import { Icon } from '../../common'

export const EditDiscussionPost = ({
  value,
  endpoint,
  contextId,
}: {
  value: string
  endpoint: string
  contextId: string
}): JSX.Element => {
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel()

  const handleSuccess = useCallback(() => setOpen(false), [setOpen])

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
            onSuccess={handleSuccess}
            endpoint={endpoint}
            method="PATCH"
            contextId={contextId}
            value={value}
          />
        </div>
      ) : null}
    </React.Fragment>
  )
}
