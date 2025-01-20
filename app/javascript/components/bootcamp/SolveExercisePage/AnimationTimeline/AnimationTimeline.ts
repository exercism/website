import { type Frame } from '@/interpreter/frames'
import anime, { type AnimeInstance, type AnimeTimelineInstance } from 'animejs'
import type { AnimeCSSProperties } from './types'

export type Animation = anime.AnimeAnimParams & {
  offset: string | number | undefined
  transformations: AnimeCSSProperties
}

export class AnimationTimeline {
  private animationTimeline: AnimeTimelineInstance
  private currentIndex: number = 0
  public currentFrame?: Frame
  public previousFrame?: Frame | null
  public nextFrame?: Frame | null
  public progress: number = 0
  private updateCallbacks: ((anim: AnimeInstance) => void)[] = []

  constructor(initialOptions: anime.AnimeParams, private frames: Frame[] = []) {
    this.animationTimeline = anime.timeline({
      easing: 'linear',
      ...initialOptions,
      update: (anim: AnimeInstance) => {
        this.updateScrubber(anim)
        this.updateCallbacks.forEach((cb) => cb(anim))
      },
    })
  }

  public destroy() {
    this.animationTimeline.pause()
    // @ts-ignore
    this.animationTimeline = null
  }

  public onUpdate(callback: (anim: AnimeInstance) => void) {
    this.updateCallbacks.push(callback)

    if (this.animationTimeline) {
      callback(this.animationTimeline)
      setTimeout(() => this.updateScrubber(this.animationTimeline), 1)
    }
  }

  public removeUpdateCallback(callback: (anim: AnimeInstance) => void) {
    this.updateCallbacks = this.updateCallbacks.filter((cb) => cb !== callback)
  }

  public populateTimeline(animations: Animation[]) {
    animations.forEach((animation: Animation) => {
      // console.log(animation.offset)
      this.animationTimeline.add(
        { ...animation, ...animation.transformations },
        animation.offset
      )
    })

    /*
     ensure the last frame is included in the timeline duration, even if it's not an animation.
     anime timeline only cares about animations when calculating duration
     and if the last frame is not an animation, it will not be included in the duration.

     example:
     - the total animation duration is 60ms
     - a new frame is added after the animation, incrementing time by 1ms (see Executor.addFrame - executor.ts#L868).
     - the last frame is now at time 61ms, but the timeline duration remains 60ms because the last frame is not animated.
     - this discrepancy prevents seeking to the last frame (time 61ms) as the timeline caps at 60ms.
    */

    /*
      on the other hand ensure the full duration of the last animation is present. hence the max function. 
      */

    const animationDurationAfterAnimations = this.animationTimeline.duration
    this.animationTimeline.duration = Math.max(
      animationDurationAfterAnimations,
      this.frames[this.frames.length - 1].time
    )
    return this
  }

  public get timeline() {
    return this.animationTimeline
  }

  public get duration() {
    return this.animationTimeline.duration
  }

  private updateScrubber(anim: AnimeInstance) {
    this.progress = anim.currentTime

    const reversedIndex = this.frames
      .slice()
      .reverse()
      .findIndex((frame) => {
        return frame.time <= this.progress
      })

    this.currentIndex = this.frames.length - 1 - reversedIndex

    this.currentFrame = this.frames[this.currentIndex]

    this.previousFrame =
      this.currentIndex > 0 ? this.frames[this.currentIndex - 1] : null

    this.nextFrame =
      this.currentIndex < this.frames.length - 1
        ? this.frames[this.currentIndex + 1]
        : null
  }

  public getProgress() {
    return this.progress
  }

  public getCurrentFrame() {
    return this.currentFrame
  }

  public get currentFrameIndex() {
    return this.currentIndex
  }

  public get framesLength() {
    return this.frames.length
  }

  public seekFirstFrame() {
    this.animationTimeline.seek(0)
  }

  public seekLastFrame() {
    this.animationTimeline.seek(this.frames[this.frames.length - 1].time)
  }

  public seekEndOfTimeline() {
    this.animationTimeline.seek(this.animationTimeline.duration)
  }

  public getFrames() {
    return this.frames
  }
  public seek(time: number) {
    this.animationTimeline.seek(time)
  }

  public play(cb?: () => void) {
    // we need to seek 0 to make sure currentFrame is the first before we start playing animation.
    // it would rewind it anyway, but the currentFrame would be the last visited frame for a moment.
    this.animationTimeline.seek(0)
    if (cb) cb()
    this.animationTimeline.play()
  }

  public pause() {
    this.animationTimeline.pause()
  }

  public get paused(): boolean {
    return this.animationTimeline.paused
  }

  public get completed(): boolean {
    return this.animationTimeline.completed
  }

  public restart() {
    this.animationTimeline.restart()
  }

  public reverse() {
    this.animationTimeline.reverse()
  }
}
