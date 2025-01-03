import { Frame } from '@/interpreter/frames'
declare global {
  type TestCallback = () => {
    slug: string
    expects: MatcherResult[]
    codeRun: string
    frames: Frame[]
    animationTimeline: TAnimationTimeline | null
    view?: HTMLElement
    imageSlug?: string
  }
}

export {}
