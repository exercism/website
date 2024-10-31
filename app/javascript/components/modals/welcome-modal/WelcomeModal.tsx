import React, { useCallback, useContext, useEffect, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '../Modal'
import { InitialView } from './InitialView'
import { SeniorView } from './DeveloperView'
import { JuniorView } from './BeginnerView'

type ViewVariant = 'initial' | 'beginner' | 'developer'

type WelcomeModalContextProps = {
  patchCloseModal: {
    mutation: () => void
  } & Pick<ReturnType<typeof useMutation>, 'status' | 'error'>
  patchUserSeniority: {
    mutation: (seniority: SeniorityLevel) => void
  } & Pick<ReturnType<typeof useMutation>, 'status' | 'error'>
  numTracks: number
  open: boolean
  setOpen: React.Dispatch<React.SetStateAction<boolean>>
  currentView: ViewVariant
  setCurrentView: React.Dispatch<React.SetStateAction<ViewVariant>>
}

type SeniorityLevel = 0 | 1 | 2 | 3 | 4
export const WelcomeModalContext =
  React.createContext<WelcomeModalContextProps>({
    patchCloseModal: {
      mutation: () => null,
      status: 'idle',
      error: null,
    },
    patchUserSeniority: {
      mutation: () => null,
      status: 'idle',
      error: null,
    },

    numTracks: 0,
    open: false,
    setOpen: () => null,
    currentView: 'initial',
    setCurrentView: () => null,
  })

export default function WelcomeModal({
  links,
  numTracks,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  links: { hideModalEndpoint: string; apiUserEndpoint: string }
  numTracks: number
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const [currentView, setCurrentView] = useState<ViewVariant>('initial')

  const {
    mutate: hideModalMutation,
    status: hideModalMutationStatus,
    error: hideModalMutationError,
  } = useMutation(
    () => {
      const { fetch } = sendRequest({
        // close modal endpoint
        endpoint: links.hideModalEndpoint,
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

  const {
    mutate: setSeniorityMutation,
    status: setSeniorityMutationStatus,
    error: setSeniorityMutationError,
  } = useMutation(
    (seniority: SeniorityLevel) => {
      const { fetch } = sendRequest({
        endpoint: links.apiUserEndpoint + `?users[seniority]=${seniority}`,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      // onSuccess: () => {
      // },
    }
  )

  return (
    <WelcomeModalContext.Provider
      value={{
        patchCloseModal: {
          mutation: hideModalMutation,
          status: hideModalMutationStatus,
          error: hideModalMutationError,
        },
        patchUserSeniority: {
          mutation: setSeniorityMutation,
          status: setSeniorityMutationStatus,
          error: setSeniorityMutationError,
        },
        open,
        setOpen,
        numTracks,
        currentView,
        setCurrentView,
      }}
    >
      <Modal
        cover={true}
        open={open}
        style={
          currentView === 'initial' ? { content: { maxWidth: '700px' } } : {}
        }
        {...props}
        onClose={() => null}
        className="m-welcome"
      >
        <Inner />
      </Modal>
    </WelcomeModalContext.Provider>
  )
}

function Inner() {
  const { currentView } = useContext(WelcomeModalContext)
  switch (currentView) {
    case 'initial':
      return <InitialView />
    case 'beginner':
      return <JuniorView />
    case 'developer':
      return <SeniorView />
    default:
      return null
  }
}
