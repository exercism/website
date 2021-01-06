import React from 'react'
import { Iteration } from './MentorDiscussion'

const formatCommentCount = (count: number) => {
  if (count >= 0 && count <= 9) {
    return count
  } else {
    return '9+'
  }
}

const Comments = ({ count }: { count: number }): JSX.Element => {
  return (
    <div className="comments" aria-hidden={true}>
      {formatCommentCount(count)}
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
      {iteration.numComments > 0 ? (
        <Comments count={iteration.numComments} />
      ) : null}
    </button>
  )
}
