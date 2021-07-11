import { useState, useRef, useEffect, useContext } from 'react'
import { PostsContext } from './PostsContext'
import { DiscussionPostProps } from './DiscussionPost'

export const usePostHighlighting = (
  posts: DiscussionPostProps[],
  userHandle: string
) => {
  const prevLastPost = useRef<DiscussionPostProps | null>(null)
  const [
    highlightedPost,
    setHighlightedPost,
  ] = useState<DiscussionPostProps | null>(null)
  const { setHasNewMessages, highlightedPostRef } = useContext(PostsContext)
  const observer = useRef<IntersectionObserver | null>()

  useEffect(() => {
    if (!highlightedPost || highlightedPost.authorHandle === userHandle) {
      return
    }

    setHasNewMessages(true)
  }, [highlightedPost, setHasNewMessages, userHandle])

  useEffect(() => {
    if (posts.length === 0) {
      return
    }

    const lastPost = posts[posts.length - 1]

    if (prevLastPost.current === lastPost) {
      return
    }

    if (prevLastPost.current === null) {
      prevLastPost.current = lastPost
      return
    }

    setHighlightedPost(lastPost)
  }, [JSON.stringify(posts)])

  useEffect(() => {
    if (!highlightedPostRef.current || !highlightedPost) {
      return
    }

    if (highlightedPost.authorHandle === userHandle) {
      highlightedPostRef.current.scrollIntoView()
    }
  }, [highlightedPost, highlightedPostRef, userHandle])

  useEffect(() => {
    if (!highlightedPostRef.current) {
      return
    }

    observer.current = new IntersectionObserver((entries) => {
      if (!entries[0].isIntersecting) {
        return
      }

      setHasNewMessages(false)
    })
    observer.current.observe(highlightedPostRef.current)

    return () => {
      observer.current?.disconnect()
    }
  }, [highlightedPost, highlightedPostRef, setHasNewMessages])

  return { highlightedPost, highlightedPostRef }
}
