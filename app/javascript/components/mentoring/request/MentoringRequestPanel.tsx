import React, { useCallback } from 'react'
import { SessionProps } from '../Session'
import { MentorDiscussion, MentoringRequest, Iteration } from '../../types'
import { StartMentoringPanel } from './StartMentoringPanel'
import { StartDiscussionPanel } from './StartDiscussionPanel'

export const MentoringRequestPanel = ({
  iterations,
  request,
  session,
  setSession,
}: {
  iterations: readonly Iteration[]
  request: MentoringRequest
  session: SessionProps
  setSession: (session: SessionProps) => void
}): JSX.Element => {
  const setDiscussion = useCallback(
    (discussion: MentorDiscussion) => {
      setSession({ ...session, discussion: discussion })
    },
    [session, setSession]
  )

  const setRequest = useCallback(
    (request: MentoringRequest) => {
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
