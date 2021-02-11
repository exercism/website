import React, { useContext } from 'react'
import { MarkAsNothingToDoButton } from './MarkAsNothingToDoButton'
import { FinishButton } from './FinishButton'
import { GraphicalIcon } from '../../common'
import { Discussion } from '../Solution'
import { DiscussionContext } from './DiscussionContext'

export const DiscussionActions = ({
  links,
  isFinished,
}: Discussion): JSX.Element => {
  const { handleFinish } = useContext(DiscussionContext)

  return (
    <div>
      {links.markAsNothingToDo ? (
        <MarkAsNothingToDoButton endpoint={links.markAsNothingToDo} />
      ) : null}

      {isFinished ? (
        <div className="finished">
          <GraphicalIcon icon="completed-check-circle" />
          Ended
        </div>
      ) : (
        <FinishButton endpoint={links.finish} onSuccess={handleFinish} />
      )}
    </div>
  )
}
