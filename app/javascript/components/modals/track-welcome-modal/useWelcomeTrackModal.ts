import { redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { useMachine } from '@xstate/react'
import { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { machine } from './LHS/TrackWelcomeModal.machine'
import { TrackWelcomeModalLinks } from './WelcomeTrackModal.types'

export function useWelcomeTrackModal(links: TrackWelcomeModalLinks) {
  const [open, setOpen] = useState(true)
  const { mutate: hideModal, status } = useMutation(
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
        handleClose()
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

  const handleClose = useCallback(() => {
    if (status === 'loading') {
      return
    }

    setOpen(false)
  }, [status])

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

  return { open, currentState, send }
}
