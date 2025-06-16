import React, { useContext, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '../Modal'
import { InitialView } from './InitialView'
import { SeniorView } from './DeveloperView'
import { JuniorView } from './JuniorView'

type ViewVariant = 'initial' | 'beginner' | 'developer'

type WelcomeModalContextProps = {
  patchCloseModal: {
    mutate: () => void
  } & Pick<ReturnType<typeof useMutation>, 'status' | 'error'>
  patchUserSeniority: {
    mutate: (seniority: SeniorityLevel) => void
  } & Pick<ReturnType<typeof useMutation>, 'status' | 'error'>
  numTracks: number
  open: boolean
  setOpen: React.Dispatch<React.SetStateAction<boolean>>
  currentView: ViewVariant
  setCurrentView: React.Dispatch<React.SetStateAction<ViewVariant>>
  links: {
    hideModalEndpoint: string
    apiUserEndpoint: string
    codingFundamentalsCourse: string
  }
}

export type SeniorityLevel =
  | 'absolute_beginner'
  | 'beginner'
  | 'junior'
  | 'mid'
  | 'senior'

export const WelcomeModalContext =
  React.createContext<WelcomeModalContextProps>({
    patchCloseModal: {
      mutate: () => null,
      status: 'idle',
      error: null,
    },
    patchUserSeniority: {
      mutate: () => null,
      status: 'idle',
      error: null,
    },

    numTracks: 0,
    open: false,
    setOpen: () => null,
    currentView: 'initial',
    setCurrentView: () => null,
    links: {
      hideModalEndpoint: '',
      apiUserEndpoint: '',
      codingFundamentalsCourse: '',
    },
  })

export default function WelcomeModal({
  links,
  numTracks,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  links: {
    hideModalEndpoint: string
    apiUserEndpoint: string
    codingFundamentalsCourse: string
  }
  numTracks: number
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const [currentView, setCurrentView] = useState<ViewVariant>('initial')

  const {
    mutate: hideModalMutation,
    status: hideModalMutationStatus,
    error: hideModalMutationError,
  } = useMutation({
    mutationFn: () => {
      const { fetch } = sendRequest({
        // close modal endpoint
        endpoint: links.hideModalEndpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: () => {
      setOpen(false)
    },
  })

  const {
    mutate: setSeniorityMutation,
    status: setSeniorityMutationStatus,
    error: setSeniorityMutationError,
  } = useMutation({
    mutationFn: (seniority: SeniorityLevel) => {
      const { fetch } = sendRequest({
        endpoint: links.apiUserEndpoint + `?user[seniority]=${seniority}`,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
  })

  return (
    <WelcomeModalContext.Provider
      value={{
        patchCloseModal: {
          mutate: hideModalMutation,
          status: hideModalMutationStatus,
          error: hideModalMutationError,
        },
        patchUserSeniority: {
          mutate: setSeniorityMutation,
          status: setSeniorityMutationStatus,
          error: setSeniorityMutationError,
        },
        open,
        setOpen,
        numTracks,
        currentView,
        setCurrentView,
        links,
      }}
    >
      <Modal
        cover={true}
        open={open}
        style={
          currentView === 'initial' ? { content: { maxWidth: '590px' } } : {}
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
