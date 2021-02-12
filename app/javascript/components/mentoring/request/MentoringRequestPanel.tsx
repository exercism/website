import React from 'react'
import { MentoringRequest, Iteration } from '../Solution'
import { StartMentoringPanel } from './StartMentoringPanel'
import { StartDiscussionPanel } from './StartDiscussionPanel'

export const MentoringRequestPanel = ({
  iterations,
  request,
}: {
  iterations: readonly Iteration[]
  request: MentoringRequest
}): JSX.Element => {
  if (request.isLocked) {
    return <StartDiscussionPanel iterations={iterations} request={request} />
  } else {
    return <StartMentoringPanel request={request} />
  }
}
