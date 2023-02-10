import React from 'react'
import dayjs from 'dayjs'
import { Avatar } from '@/components/common'
import { RepresentationFeedbackType, User } from '@/components/types'
import { useHighlighting } from '@/hooks'
import { CommentTag } from '../common/CommentTag'

export type PreviewFeedbackCommentProps = {
  html: string
  feedbackType: RepresentationFeedbackType
  mentor: Pick<User, 'avatarUrl' | 'handle'> & { name: string }
}

export function PreviewFeedbackComment({
  html,
  mentor,
  feedbackType,
}: PreviewFeedbackCommentProps): JSX.Element {
  const htmlRef = useHighlighting<HTMLDivElement>(html)

  return (
    <div className="px-24 py-16 leading-160 overflow-auto">
      <div className="flex flex-row items-center mb-12">
        <Avatar className="w-[32px] h-[32px] mr-16" src={mentor.avatarUrl} />
        <div className="text-15 text-btnBorder font-medium">
          <span className="text-textColor1">{mentor.name}</span> gave this
          feedback on a solution exactly like yours:
        </div>{' '}
      </div>

      <div className="flex flex-start">
        <CommentTag type={feedbackType} />
      </div>
      <div
        className="mb-4"
        ref={htmlRef}
        dangerouslySetInnerHTML={{ __html: html }}
      ></div>
      <div className="text-btnBorder font-medium">
        Commented on {`${dayjs(Date.now()).format('D MMM YYYY')}`}
      </div>
    </div>
  )
}
