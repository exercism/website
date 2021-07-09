import { Iteration } from '../../../types'

export const useListTrimming = <T extends Iteration>(iterations: T[]): T[] => {
  const startIteration = iterations.findIndex(
    (iteration) => iteration.posts && iteration.posts.length !== 0
  )

  return iterations.slice(startIteration)
}
