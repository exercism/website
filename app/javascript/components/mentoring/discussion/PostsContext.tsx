import React, { createContext, useRef, useState } from 'react'
import { MentorDiscussion } from '../../types'

type PostsContextType = {
  cacheKey: string
  hasNewMessages: boolean
  setHasNewMessages: (value: boolean) => void
  highlightedPostRef: React.MutableRefObject<HTMLDivElement | null>
}

export const PostsContext = createContext<PostsContextType>({
  cacheKey: '',
  hasNewMessages: false,
  setHasNewMessages: () => {},
  highlightedPostRef: { current: null },
})

export const PostsWrapper = ({
  discussion,
  children,
}: React.PropsWithChildren<{ discussion?: MentorDiscussion }>): JSX.Element => {
  const cacheKey = `posts-discussion-${discussion?.uuid}`
  const [hasNewMessages, setHasNewMessages] = useState(false)
  const highlightedPostRef = useRef<HTMLDivElement | null>(null)

  if (!discussion) {
    return <React.Fragment>{children}</React.Fragment>
  }

  return (
    <PostsContext.Provider
      value={{
        cacheKey,
        hasNewMessages,
        setHasNewMessages,
        highlightedPostRef,
      }}
    >
      {children}
    </PostsContext.Provider>
  )
}
