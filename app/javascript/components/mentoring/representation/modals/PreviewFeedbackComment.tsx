import React from 'react'
import { Avatar } from '../../../common'
import { User } from '../../../types'
import dayjs from 'dayjs'

export type PreviewFeedbackCommentProps = {
  html: string
  mentor: Pick<User, 'avatarUrl' | 'handle'> & { name: string }
}

export function PreviewFeedbackComment({
  html,
  mentor,
}: PreviewFeedbackCommentProps): JSX.Element {
  return (
    <div className="px-24 py-16 leading-160">
      <div className="flex flex-row items-center mb-12">
        <Avatar className="w-[32px] h-[32px] mr-16" src={mentor.avatarUrl} />
        <div className="text-15 text-btnBorder font-medium">
          <span className="text-primaryBtnBorder">{mentor.name}</span> gave this
          feedback on a solution exactly like yours:
        </div>{' '}
      </div>

      <div className="mb-4" dangerouslySetInnerHTML={{ __html: html }}></div>
      <div className="text-btnBorder font-medium">
        Commented on {`${dayjs(Date.now()).format('D MMM YYYY')}`}
      </div>
    </div>
  )
}
