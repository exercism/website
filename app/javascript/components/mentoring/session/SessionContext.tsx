import React from 'react'
import { SessionProps } from '../Session'
import { DiscussionWrapper } from '../discussion/DiscussionContext'

export const SessionContext = ({
  session,
  setSession,
  children,
}: React.PropsWithChildren<{
  session: SessionProps
  setSession: (session: SessionProps) => void
}>): JSX.Element => {
  const Wrapper = session.discussion ? DiscussionWrapper : GenericWrapper

  return (
    <Wrapper session={session} setSession={setSession}>
      {children}
    </Wrapper>
  )
}

const GenericWrapper = ({
  children,
}: React.PropsWithChildren<{
  session: SessionProps
  setSession: (session: SessionProps) => void
}>) => {
  return <React.Fragment>{children}</React.Fragment>
}
