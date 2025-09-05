import React, { useContext } from 'react'
import { PostsContext } from './PostsContext'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const NewMessageAlert = ({
  onClick = () => {},
}: {
  onClick?: () => void
}): JSX.Element | null => {
  const { t } = useAppTranslation()
  const { hasNewMessages, highlightedPostRef } = useContext(PostsContext)

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
      <span>{t('newMessage')}</span>
    </button>
  )
}
