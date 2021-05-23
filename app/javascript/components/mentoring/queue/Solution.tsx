import React, { forwardRef } from 'react'
import { fromNow } from '../../../utils/time'
import { ExerciseIcon } from '../../common/ExerciseIcon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'
import { Avatar } from '../../common/Avatar'
import { StudentTooltip } from '../../tooltips'
import { usePanel } from '../../../hooks/use-panel'

type SolutionProps = {
  studentAvatarUrl: string
  studentHandle: string
  exerciseTitle: string
  exerciseIconUrl: string
  isFavorited: boolean
  haveMentoredPreviously: boolean
  status: string
  updatedAt: string
  url: string
  tooltipUrl: string
}

export const Solution = ({
  studentAvatarUrl,
  studentHandle,
  exerciseTitle,
  exerciseIconUrl,
  isFavorited,
  haveMentoredPreviously,
  status,
  updatedAt,
  url,
  tooltipUrl,
}: SolutionProps): JSX.Element => {
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel({
    placement: 'right',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [-20, -0],
        },
      },
    ],
  })

  return (
    <>
      <ReferenceElement
        href={url}
        className="--solution"
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
      >
        <ExerciseIcon title={exerciseTitle} iconUrl={exerciseIconUrl} />
        <Avatar src={studentAvatarUrl} handle={studentHandle} />
        <div className="--info">
          <div className="--handle">
            {studentHandle}
            {isFavorited ? (
              <Icon
                icon="gold-star"
                alt="Favorite student"
                className="favorited"
              />
            ) : haveMentoredPreviously ? (
              <Icon
                icon="mentoring"
                alt="Mentored previously"
                className="previously-mentored"
              />
            ) : null}
          </div>
          <div className="--exercise-title">on {exerciseTitle}</div>
        </div>
        {status ? <div className="--status">{status}</div> : null}
        <time className="-updated-at">{fromNow(updatedAt)}</time>
        <GraphicalIcon icon="chevron-right" className="action-icon" />
      </ReferenceElement>
      {open ? (
        <StudentTooltip
          endpoint={tooltipUrl}
          requestId={tooltipUrl}
          {...panelAttributes}
        />
      ) : null}
    </>
  )
}

const ReferenceElement = forwardRef<
  HTMLElement,
  React.HTMLProps<HTMLAnchorElement>
>(({ ...props }, ref) => {
  return (
    <a ref={ref as React.RefObject<HTMLAnchorElement>} {...props}>
      {props.children}
    </a>
  )
})
