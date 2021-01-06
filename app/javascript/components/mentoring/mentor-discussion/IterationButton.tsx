import React from 'react'
import { Iteration } from '../MentorDiscussion'

const formatCommentCount = (count: number) => {
  return count > 9 ? '9+' : count
}

const Comments = ({ iteration }: { iteration: Iteration }): JSX.Element => {
  const classNames = ['comments']

  if (iteration.unread) {
    classNames.push('unread')
  }

  return (
    <div className={classNames.join(' ')} aria-hidden={true}>
      {formatCommentCount(iteration.numComments)}
    </div>
  )
}

export const IterationButton = ({
  iteration,
  selected,
  onClick,
}: {
  iteration: Iteration
  selected: boolean
  onClick: () => void
}): JSX.Element => {
  const classNames = ['iteration']
  const label = [`Go to iteration ${iteration.idx}`]

  if (selected) {
    classNames.push('active')
  }

  if (iteration.numComments > 0) {
    label.push(`${formatCommentCount(iteration.numComments)} comments`)
  }

  return (
    <button
      type="button"
      className={classNames.join(' ')}
      aria-current={selected}
      aria-label={label.join(', ')}
      disabled={selected}
      onClick={onClick}
    >
      {iteration.idx}
      {iteration.numComments > 0 ? <Comments iteration={iteration} /> : null}
    </button>
  )
}
