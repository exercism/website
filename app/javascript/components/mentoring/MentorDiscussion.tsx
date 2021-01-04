import React from 'react'
import { MentoringPanelList } from './MentoringPanelList'

type Links = {
  posts: string
  scratchpad: string
}

export const MentorDiscussion = ({
  links,
  discussionId,
  iterationIdx,
}: {
  links: Links
  discussionId: number
  iterationIdx: number
}): JSX.Element => {
  return (
    <div className="c-mentor-discussion">
      <div className="rhs">
        <MentoringPanelList
          links={links}
          discussionId={discussionId}
          iterationIdx={iterationIdx}
        />
      </div>
    </div>
  )
}
