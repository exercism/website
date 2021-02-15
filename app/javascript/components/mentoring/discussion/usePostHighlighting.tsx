import React, { useState, useRef, useEffect, useContext } from 'react'
import { PostsContext } from '../discussion/DiscussionContext'
import { DiscussionPostProps } from './DiscussionPost'

export const usePostHighlighting = (
  data: DiscussionPostProps[] | undefined,
  userId: number
) => {
  const hasLoadedRef = useRef(false)
  const [
    highlightedPost,
    setHighlightedPost,
  ] = useState<DiscussionPostProps | null>(null)
  const { setHasNewMessages, highlightedPostRef } = useContext(PostsContext)
  const observer = useRef<IntersectionObserver | null>()

  useEffect(() => {
    if (!highlightedPostRef.current || !highlightedPost) {
      return
    }

    if (highlightedPost.authorId === userId) {
      highlightedPostRef.current.scrollIntoView()
    }
  }, [highlightedPost, highlightedPostRef, userId])

  useEffect(() => {
    if (!data || data.length === 0) {
      return
    }

    if (!hasLoadedRef.current) {
      hasLoadedRef.current = true

      return
    }

    const lastPost = data[data.length - 1]

    setHighlightedPost(lastPost)

    if (lastPost.authorId !== userId) {
      setHasNewMessages(true)
    }
  }, [data, setHasNewMessages, userId])

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
  }, [data, highlightedPost, highlightedPostRef, setHasNewMessages])

  return {
    highlightedPost,
    highlightedPostRef,
  }
}
