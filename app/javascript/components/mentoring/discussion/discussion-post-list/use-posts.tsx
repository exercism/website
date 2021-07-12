import { useMemo } from 'react'
import { DiscussionPostProps } from '../DiscussionPost'
import { Iteration } from '../../../types'

export const usePosts = (
  iterations: readonly Iteration[]
): DiscussionPostProps[] => {
  return useMemo(() => {
    return iterations.reduce<DiscussionPostProps[]>((posts, iteration) => {
      return posts.concat(iteration.posts || [])
    }, [])
  }, [JSON.stringify(iterations)])
}
