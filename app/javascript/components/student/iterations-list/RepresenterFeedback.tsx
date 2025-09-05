// i18n-key-prefix: representerFeedback
// i18n-namespace: components/student/iterations-list
import React from 'react'
import { Avatar } from '@/components/common'
import type { RepresenterFeedback as Props } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const RepresenterFeedback = ({
  html,
  author,
  editor,
}: Props): JSX.Element => {
  const { t } = useAppTranslation()

  return (
    <div className="c-automated-feedback representer-feedback">
      <div className="feedback-header">
        <Avatar
          src={author.avatarUrl}
          handle={author.name}
          className="place-self-start"
        />
        <div className="info">
          <Trans
            i18nKey="representerFeedback.gaveFeedback"
            ns="components/student/iterations-list"
            values={{ authorName: author.name }}
            components={{
              strong: <strong className="inline-block" />,
            }}
          />
          <EditedBy editor={editor} author={author} />:
        </div>
      </div>
      <div className="comment">
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: html }}
        />
      </div>
    </div>
  )
}

export function EditedBy({
  author,
  editor,
}: Pick<Props, 'author' | 'editor'>): JSX.Element | null {
  const { t } = useAppTranslation()

  if (!editor || editor.name === author.name) return null

  return (
    <em>
      &nbsp;(
      <Trans
        i18nKey="representerFeedback.editedBy"
        ns="components/student/iterations-list"
        values={{ editorName: editor.name }}
        components={{ strong: <strong /> }}
      />
      )
    </em>
  )
}
