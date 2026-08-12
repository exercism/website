import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { fromNow } from '../../../utils/time'
import { Icon } from '../../common'
import {
  UserAvatar,
  UserHandleWithFlair,
  UserReputation,
} from '../../user-identity'
import { ViewingComponentType } from '../../common/ListItem'
import { SolutionComment } from '../../types'

export const CommentView = ({
  item: comment,
  onEdit,
}: ViewingComponentType<SolutionComment>): JSX.Element => {
  const { t } = useAppTranslation('components/community-solutions')
  const isEditable = comment.links.edit

  return (
    <div className="comment">
      <header className="flex items-center mb-16">
        <UserAvatar handle={comment.author.handle} />
        <div className="flex flex-col">
          <div className="flex items-center">
            <div className="text-h6 mr-8">
              <UserHandleWithFlair handle={comment.author.handle} />
            </div>
            <UserReputation handle={comment.author.handle} size="small" />
          </div>
          <div className="text-tetColor6 leading-160">
            {fromNow(comment.updatedAt)}
          </div>
        </div>
        {isEditable ? (
          <button type="button" className="edit-button" onClick={onEdit}>
            <Icon icon="edit" alt="Edit" />
            <span>{t('commentsList.commentView.edit')}</span>
          </button>
        ) : null}
      </header>
      <div
        className="c-textual-content --small"
        dangerouslySetInnerHTML={{ __html: comment.contentHtml }}
      />
    </div>
  )
}
