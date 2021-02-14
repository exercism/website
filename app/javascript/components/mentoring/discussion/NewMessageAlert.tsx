import React, { useContext } from 'react'
import { DiscussionContext } from './DiscussionContext'
import { GraphicalIcon } from '../../common'

export const NewMessageAlert = ({
  onClick,
}: {
  onClick: () => void
}): JSX.Element | null => {
  const { hasNewMessages, highlightedPostRef } = useContext(DiscussionContext)

  if (!hasNewMessages) {
    return null
  }

  return (
    <button
      className="new-messages-button"
      type="button"
      onClick={() => {
        onClick()
        highlightedPostRef.current?.scrollIntoView()
      }}
    >
      <GraphicalIcon icon="comment" />
      <span>New Message</span>
    </button>
  )
}
