import React from 'react'
import { FinishButton } from './FinishButton'
import { MentorDiscussion } from '../../types'

type Links = {
  exercise: string
}

export const DiscussionActions = ({
  discussion,
  links,
}: {
  discussion: MentorDiscussion
  links: Links
}): JSX.Element => {
  return <FinishButton discussion={discussion} links={links} />
}
