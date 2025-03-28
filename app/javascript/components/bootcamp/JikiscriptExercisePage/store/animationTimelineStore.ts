import { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import { createStoreWithMiddlewares } from './utils'

type AnimationTimelineStore = {
  animationTimeline: AnimationTimeline | undefined
  setAnimationTimeline: (animationTimeline: AnimationTimeline) => void
  isTimelineComplete: boolean
  setIsTimelineComplete: (isTimelineComplete: boolean) => void
  shouldAutoplayAnimation: boolean
  setShouldAutoplayAnimation: (shouldAutoplayAnimation: boolean) => void
}

const useAnimationTimelineStore =
  createStoreWithMiddlewares<AnimationTimelineStore>(
    (set) => ({
      animationTimeline: undefined,
      setAnimationTimeline: (animationTimeline) => {
        set(
          { animationTimeline },
          false,
          'animationTimelineStore/setAnimationTimeline'
        )
      },
      isTimelineComplete: false,
      setIsTimelineComplete: (isTimelineComplete) => {
        set(
          { isTimelineComplete },
          false,
          'animationTimelineStore/setIsTimelineComplete'
        )
      },
      shouldAutoplayAnimation: false,
      setShouldAutoplayAnimation: (shouldAutoplayAnimation) => {
        set(
          { shouldAutoplayAnimation },
          false,
          'animationTimelineStore/setShouldAutoplayAnimation'
        )
      },
    }),
    'AnimationTimelineStore'
  )

export default useAnimationTimelineStore
