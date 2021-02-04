import React, { useReducer, useCallback } from 'react'
import { Modal } from './Modal'
import { AboutToEndSession } from './end-session-modal/AboutToEndSession'
import { SessionEnded } from './end-session-modal/SessionEnded'

export type Discussion = {
  student: {
    handle: string
    links: {
      mentorAgain: string
    }
  }
}

type ModalState =
  | { step: 'aboutToEnd'; discussion: null }
  | { step: 'ended'; discussion: Discussion }

type Action = { type: 'SESSION_ENDED'; payload: { discussion: Discussion } }

function reducer(state: ModalState, action: Action): ModalState {
  switch (action.type) {
    case 'SESSION_ENDED':
      return { step: 'ended', discussion: action.payload.discussion }
  }
}

export const EndSessionModal = ({
  endpoint,
  open,
  ...props
}: {
  endpoint: string
  open: boolean
}): JSX.Element => {
  const [state, dispatch] = useReducer(reducer, {
    step: 'aboutToEnd',
    discussion: null,
  })

  const handleSessionEnded = useCallback((discussion) => {
    dispatch({ type: 'SESSION_ENDED', payload: { discussion: discussion } })
  }, [])

  return (
    <Modal
      open={open}
      onClose={() => {}}
      className="end-session-modal"
      {...props}
    >
      {state.step === 'aboutToEnd' ? (
        <AboutToEndSession endpoint={endpoint} onSuccess={handleSessionEnded} />
      ) : null}
      {state.step === 'ended' ? (
        <SessionEnded discussion={state.discussion} />
      ) : null}
    </Modal>
  )
}
