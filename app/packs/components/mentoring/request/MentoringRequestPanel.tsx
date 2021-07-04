import React, { useCallback } from 'react'
import { SessionProps } from '../Session'
import {
  MentorDiscussion as Discussion,
  MentorSessionRequest as Request,
  Iteration,
} from '../../types'
import { StartMentoringPanel } from './StartMentoringPanel'
import { StartDiscussionPanel } from './StartDiscussionPanel'

export const MentoringRequestPanel = ({
  iterations,
  request,
  session,
  setSession,
}: {
  iterations: readonly Iteration[]
  request: Request
  session: SessionProps
  setSession: (session: SessionProps) => void
}): JSX.Element => {
  const setDiscussion = useCallback(
    (discussion: Discussion) => {
      setSession({ ...session, discussion: discussion })
    },
    [session, setSession]
  )

  const setRequest = useCallback(
    (request: Request) => {
      setSession({ ...session, request: request })
    },
    [session, setSession]
  )

  if (request.isLocked) {
    return (
      <StartDiscussionPanel
        iterations={iterations}
        request={request}
        setDiscussion={setDiscussion}
      />
    )
  } else {
    return <StartMentoringPanel request={request} setRequest={setRequest} />
  }
}
