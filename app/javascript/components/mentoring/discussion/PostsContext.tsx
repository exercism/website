import React, { createContext, useRef, useState } from 'react'
import { Discussion } from '../Session'

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
  discussionId,
  children,
}: React.PropsWithChildren<{ discussionId?: string }>): JSX.Element => {
  const [hasNewMessages, setHasNewMessages] = useState(false)
  const highlightedPostRef = useRef<HTMLDivElement | null>(null)

  if (!discussionId) {
    return <React.Fragment>{children}</React.Fragment>
  }

  return (
    <PostsContext.Provider
      value={{
        cacheKey: `posts-discussion-${discussionId}`,
        hasNewMessages,
        setHasNewMessages,
        highlightedPostRef,
      }}
    >
      {children}
    </PostsContext.Provider>
  )
}
