import { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import { createStoreWithMiddlewares } from './utils'

// Might not need this whole store.
type AnimationTimelineStore = {
  animationTimeline: AnimationTimeline | undefined
  setAnimationTimeline: (animationTimeline: AnimationTimeline) => void
}

const useAnimationTimelineStore =
  createStoreWithMiddlewares<AnimationTimelineStore>(
    (set) => ({
      animationTimeline: undefined,
      setAnimationTimeline: (animationTimeline) => {
        set({ animationTimeline }, false, 'exercise/setTestResults')
      },
    }),
    'AnimationTimelineStore'
  )

export default useAnimationTimelineStore
