import React, { useReducer, useCallback } from 'react'
import { Modal } from './Modal'
import { AboutToFinishDiscussion } from './finish-mentor-discussion-modal/AboutToFinishDiscussion'
import { DiscussionFinished } from './finish-mentor-discussion-modal/DiscussionFinished'

export type Relationship = {
  isFavorited: boolean
  links: {
    block: string
    favorite: string
  }
}

export type Discussion = {
  student: {
    handle: string
  }
  relationship: Relationship
}

type ModalState =
  | { step: 'aboutToEnd'; discussion: null }
  | { step: 'ended'; discussion: Discussion }

type Action = {
  type: 'DISCUSSION_FINISHED'
  payload: { discussion: Discussion }
}

function reducer(state: ModalState, action: Action): ModalState {
  switch (action.type) {
    case 'DISCUSSION_FINISHED':
      return { step: 'ended', discussion: action.payload.discussion }
  }
}

export const FinishMentorDiscussionModal = ({
  endpoint,
  open,
  onCancel,
  ...props
}: {
  endpoint: string
  open: boolean
  onCancel: () => void
}): JSX.Element => {
  const [state, dispatch] = useReducer(reducer, {
    step: 'aboutToEnd',
    discussion: null,
  })

  const handleDiscussionFinished = useCallback((discussion) => {
    dispatch({
      type: 'DISCUSSION_FINISHED',
      payload: { discussion: discussion },
    })
  }, [])

  return (
    <Modal
      open={open}
      onClose={() => {}}
      className="m-finish-mentor-discussion"
      {...props}
    >
      {state.step === 'aboutToEnd' ? (
        <AboutToFinishDiscussion
          endpoint={endpoint}
          onSuccess={handleDiscussionFinished}
          onCancel={onCancel}
        />
      ) : null}
      {state.step === 'ended' ? (
        <DiscussionFinished discussion={state.discussion} />
      ) : null}
    </Modal>
  )
}
