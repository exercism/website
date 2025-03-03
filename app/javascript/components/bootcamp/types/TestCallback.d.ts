import { Frame } from '@/interpreter/frames'
declare global {
  type TestCallback = () => {
    slug: string
    expects: MatcherResult[]
    codeRun: string
    frames: Frame[]
    animationTimeline: TAnimationTimeline | null
    type: TestsType
    view?: HTMLElement
    imageSlug?: string
  }
}

export {}
