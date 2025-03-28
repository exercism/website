import React from 'react'
import { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import { assembleClassNames } from '@/utils/assemble-classnames'
export function TooltipInformation({
  hasCodeBeenEdited,
  notEnoughFrames,
  animationTimeline,
}: {
  hasCodeBeenEdited: boolean
  notEnoughFrames: boolean
  animationTimeline: AnimationTimeline
}) {
  // editing code removes frames anyway, so this has to be higher precedence
  if (hasCodeBeenEdited) {
    return (
      <StaticTooltip text="Scrubber is disabled because the code has been edited" />
    )
  }

  // Don't show this if it's a scrubbable animation timeline
  if (notEnoughFrames && !animationTimeline) {
    return (
      <StaticTooltip text="There is only one frame. You can inspect that by toggling the information widget." />
    )
  }
}

export function StaticTooltip({
  text,
  className,
  style,
}: {
  text: string
  className?: string
  style?: React.CSSProperties | undefined
}) {
  return (
    <div
      style={style}
      className={assembleClassNames(
        'absolute left-1/2 -top-10 py-4 px-8 -translate-x-1/2 -translate-y-[100%] hidden group-hover:block bg-gray-800 text-[#fafaff] text-sm rounded shadow-lg',
        className
      )}
      role="tooltip"
    >
      {text}
    </div>
  )
}
