import React, { useState, useCallback } from 'react'
import { SessionProps } from '../Session'
import { MentorSessionRequest as Request, Iteration } from '../../types'
import { StartMentoringPanel } from './StartMentoringPanel'
import { StartDiscussionPanel } from './StartDiscussionPanel'

type Links = {
  mentoringDocs: string
}

export const MentoringRequestPanel = ({
  iterations,
  request,
  session,
  setSession,
  links,
}: {
  iterations: readonly Iteration[]
  request: Request
  session: SessionProps
  setSession: (session: SessionProps) => void
  links: Links
}): JSX.Element => {
  const [justLocked, setJustLocked] = useState(false)

  const handleRequestLock = useCallback(
    (request: Request) => {
      setJustLocked(true)
      setSession({ ...session, request: request })
    },
    [session, setSession]
  )

  if (request.isLocked) {
    return (
      <StartDiscussionPanel
        iterations={iterations}
        request={request}
        links={links}
        defaultExpanded={justLocked}
      />
    )
  } else {
    return <StartMentoringPanel request={request} onLock={handleRequestLock} />
  }
}
