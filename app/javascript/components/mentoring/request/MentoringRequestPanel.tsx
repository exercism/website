import React, { useCallback } from 'react'
import { SessionProps } from '../Session'
import { MentorSessionRequest as Request, Iteration } from '../../types'
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
  const setRequest = useCallback(
    (request: Request) => {
      setSession({ ...session, request: request })
    },
    [session, setSession]
  )

  if (request.isLocked) {
    return <StartDiscussionPanel iterations={iterations} request={request} />
  } else {
    return <StartMentoringPanel request={request} setRequest={setRequest} />
  }
}
