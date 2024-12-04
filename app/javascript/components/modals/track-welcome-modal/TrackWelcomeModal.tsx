import React, { createContext } from 'react'

import { Track } from '@/components/types'
import { Modal, ModalProps } from '../Modal'
import { TrackWelcomeModalRHS as RHS } from './RHS/TrackWelcomeModalRHS'
import { TrackWelcomeModalLHS as LHS } from './LHS/TrackWelcomeModalLHS'
import { useTrackWelcomeModal } from './useTrackWelcomeModal'
import {
  CurrentState,
  TrackWelcomeModalLinks,
  TrackWelcomeModalProps,
} from './TrackWelcomeModal.types'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { ErrorFallback } from '@/components/common/ErrorFallback'
import { SeniorityLevel } from '../welcome-modal/WelcomeModal'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export const TrackContext = createContext<{
  track: Track
  currentState: CurrentState
  send: any
  links: TrackWelcomeModalLinks
  userSeniority: SeniorityLevel
  shouldShowBootcampRecommendationView: boolean
  hideBootcampRecommendationView: () => void
}>({
  track: {} as Track,
  currentState: {} as CurrentState,
  send: () => {},
  links: {} as TrackWelcomeModalLinks,
  userSeniority: '' as SeniorityLevel,
  shouldShowBootcampRecommendationView: false,
  hideBootcampRecommendationView: () => {},
})

export const TrackWelcomeModal = ({
  links,
  track,
  userSeniority,
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> &
  TrackWelcomeModalProps): JSX.Element => {
  const {
    open,
    currentState,
    send,
    error: modalDismissalError,
    shouldShowBootcampRecommendationView,
    hideBootcampRecommendationView,
  } = useTrackWelcomeModal(links, userSeniority)

  return (
    <Modal
      cover={true}
      open={open}
      onClose={() => null}
      className="m-track-welcome-modal"
    >
      <TrackContext.Provider
        value={{
          track,
          currentState,
          send,
          links,
          userSeniority,
          shouldShowBootcampRecommendationView,
          hideBootcampRecommendationView,
        }}
      >
        <div className="flex">
          <LHS />
          <RHS />
        </div>
      </TrackContext.Provider>
      <ErrorBoundary
        FallbackComponent={(props) => (
          <ErrorFallback error={props.error} className="mb-12" />
        )}
      >
        <ErrorMessage
          error={modalDismissalError}
          defaultError={DEFAULT_ERROR}
        />
      </ErrorBoundary>
    </Modal>
  )
}
