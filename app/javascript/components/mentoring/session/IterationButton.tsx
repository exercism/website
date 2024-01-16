import React from 'react'
import pluralize from 'pluralize'
import { Iteration } from '../../types'

class IterationWithCount {
  iteration: Iteration

  constructor(iteration: Iteration) {
    this.iteration = iteration
  }

  get numComments(): number {
    if (!this.iteration.posts) {
      return 0
    }

    return this.iteration.posts.length
  }

  get unread() {
    return this.iteration.unread
  }
}

const formatCommentCount = (count: number) => {
  return count > 9 ? '9+' : count
}

const CommentsCount = ({
  iteration,
}: {
  iteration: IterationWithCount
}): JSX.Element => {
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

const NewLabel = (): JSX.Element => {
  return (
    <div className="new" aria-hidden={true}>
      New
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
  const iterationWithCount = new IterationWithCount(iteration)

  if (selected) {
    classNames.push('active')
  }

  if (iterationWithCount.numComments > 0) {
    label.push(
      `${formatCommentCount(iterationWithCount.numComments)} ${pluralize(
        'comment',
        iterationWithCount.numComments
      )}`
    )
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
      {iteration.new && iterationWithCount.numComments === 0 && <NewLabel />}
      {iterationWithCount.numComments > 0 ? (
        <CommentsCount iteration={iterationWithCount} />
      ) : null}
    </button>
  )
}
