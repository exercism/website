import React, { useCallback } from 'react'
import { usePanel } from '../../../hooks/use-panel'
import { DiscussionPostForm } from './DiscussionPostForm'
import { GraphicalIcon } from '../../common/GraphicalIcon'

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
        <GraphicalIcon icon="edit" />
        <span>Edit</span>
      </button>
      {open ? (
        <div {...panelAttributes}>
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
