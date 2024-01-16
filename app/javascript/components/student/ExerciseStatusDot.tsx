import React, { forwardRef } from 'react'
import { ExerciseStatus } from '../types'
import { ExerciseTooltip } from '../tooltips'
import { ExercismTippy } from '../misc/ExercismTippy'

export default function ExerciseStatusDot({
  exerciseStatus,
  type,
  links,
}: {
  exerciseStatus: ExerciseStatus
  type: string
  links: {
    tooltip: string
    exercise?: string
  }
}): JSX.Element {
  return (
    <ExercismTippy content={<ExerciseTooltip endpoint={links.tooltip} />}>
      <ReferenceElement
        className={`c-ed --${exerciseStatus} --${type}`}
        link={links.exercise}
        status={exerciseStatus}
      />
    </ExercismTippy>
  )
}

const ReferenceElement = forwardRef<
  HTMLElement,
  React.HTMLProps<HTMLDivElement> &
    React.HTMLProps<HTMLAnchorElement> & {
      link?: string
      status: ExerciseStatus
    }
>(({ link, status, ...props }, ref) => {
  return link ? (
    <a
      href={link}
      onClick={(e) => {
        if (status === 'locked') {
          e.preventDefault()
        }
      }}
      ref={ref as React.RefObject<HTMLAnchorElement>}
      {...props}
    />
  ) : (
    <div ref={ref as React.RefObject<HTMLDivElement>} {...props} />
  )
})
