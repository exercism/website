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
  const {
    open,
    setOpen,
    setButtonElement,
    setPanelElement,
    styles,
    attributes,
  } = usePanel()

  const handleSuccess = useCallback(() => setOpen(false), [setOpen])

  return (
    <React.Fragment>
      <button
        ref={setButtonElement}
        onClick={() => {
          setOpen(!open)
        }}
        type="button"
        className="edit-button"
      >
        <GraphicalIcon icon="edit" />
        <span>Edit</span>
      </button>
      <div ref={setPanelElement} style={styles.popper} {...attributes.popper}>
        {open ? (
          <DiscussionPostForm
            onSuccess={handleSuccess}
            endpoint={endpoint}
            method="PATCH"
            contextId={contextId}
            value={value}
          />
        ) : null}
      </div>
    </React.Fragment>
  )
}
