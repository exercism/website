import React, { createContext } from 'react'

// import { FormButton } from '../common'
// import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'
import { Track } from '@/components/types'
import { Modal, ModalProps } from '../Modal'
import { TrackWelcomeModalRHS as RHS } from './RHS'
import { Choices } from './LHS/steps/components/Choices'
import { TrackWelcomeModalLHS as LHS } from './LHS/TrackWelcomeModalLHS'
import { useWelcomeTrackModal } from './useWelcomeTrackModal'
import { CurrentState, TrackWelcomeModalProps } from './WelcomeTrackModal.types'

// const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const TrackContext = createContext<{
  track: Track
  currentState: CurrentState
  send: any
}>({
  track: {} as Track,
  currentState: {} as CurrentState,
  send: () => {},
})

export const TrackWelcomeModal = ({
  links,
  track,
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> &
  TrackWelcomeModalProps): JSX.Element => {
  const { open, currentState, send } = useWelcomeTrackModal(links)
  return (
    <Modal
      cover={true}
      open={open}
      onClose={() => null}
      className="m-track-welcome-modal"
    >
      <TrackContext.Provider value={{ track, currentState, send }}>
        <div className="flex">
          <LHS />
          <RHS />
        </div>
        {/*<Choices />*/}
      </TrackContext.Provider>
    </Modal>
  )
}
