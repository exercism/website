import { redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { useMachine } from '@xstate/react'
import { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { machine } from './LHS/TrackWelcomeModal.machine'
import { TrackWelcomeModalLinks } from './TrackWelcomeModal.types'
import { SeniorityLevel } from '../welcome-modal/WelcomeModal'

export function useTrackWelcomeModal(
  links: TrackWelcomeModalLinks,
  userSeniority: SeniorityLevel,
  userJoinedDaysAgo: number
) {
  const [open, setOpen] = useState(true)

  const [
    shouldShowBootcampRecommendationView,
    setShouldShowBootcampRecommendationView,
  ] = useState(
    !userSeniority ||
      (userSeniority.includes('beginner') && userJoinedDaysAgo >= 7)
  )

  const hideBootcampRecommendationView = useCallback(() => {
    setShouldShowBootcampRecommendationView(false)
  }, [])

  const { mutate: hideModal, error } = useMutation({
    mutationFn: () => {
      const { fetch } = sendRequest({
        endpoint: links.hideModal,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: () => {
      setOpen(false)
    },
  })

  const { mutate: activateLearningMode } = useMutation({
    mutationFn: () => {
      const { fetch } = sendRequest({
        endpoint: links.activateLearningMode,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
  })

  const { mutate: activatePracticeMode } = useMutation({
    mutationFn: () => {
      const { fetch } = sendRequest({
        endpoint: links.activatePracticeMode,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
  })

  const [currentState, send] = useMachine(machine, {
    actions: {
      handleContinueToLocalMachine() {
        hideModal()
      },
      handleContinueToOnlineEditor() {
        hideModal()
        redirectTo(links.editHelloWorld)
      },
      handleSelectLearningMode() {
        activateLearningMode()
      },
      handleSelectPracticeMode() {
        activatePracticeMode()
      },
    },
  })

  return {
    open,
    currentState,
    send,
    error,
    shouldShowBootcampRecommendationView,
    hideBootcampRecommendationView,
  }
}
