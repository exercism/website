import { redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { useMachine } from '@xstate/react'
import { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { machine } from './LHS/TrackWelcomeModal.machine'
import { TrackWelcomeModalLinks } from './TrackWelcomeModal.types'

export function useTrackWelcomeModal(links: TrackWelcomeModalLinks) {
  const [open, setOpen] = useState(true)
  const {
    mutate: hideModal,
    status,
    error,
  } = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.hideModal,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => {
        setOpen(false)
      },
    }
  )

  const { mutate: activateLearningMode } = useMutation(() => {
    const { fetch } = sendRequest({
      endpoint: links.activateLearningMode,
      method: 'PATCH',
      body: null,
    })

    return fetch
  })

  const { mutate: activatePracticeMode } = useMutation(() => {
    const { fetch } = sendRequest({
      endpoint: links.activatePracticeMode,
      method: 'PATCH',
      body: null,
    })

    return fetch
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

  return { open, currentState, send, error }
}
