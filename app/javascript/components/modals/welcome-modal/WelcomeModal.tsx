import React, { useCallback, useContext, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '../Modal'
import { InitialView } from './InitialView'
import { SeniorView } from './DeveloperView'
import { JuniorView } from './BeginnerView'

export const VIEW_CHANGER_BUTTON_CLASS =
  'cursor-pointer text-18 font-semibold rounded-8 border-1 border-borderColor1 px-12 py-8 h-[56px] pointer-events-auto'

type ViewVariant = 'initial' | 'beginner' | 'developer'

type WelcomeModalContextProps = {
  closeModal: {
    handleCloseModal: () => void
  } & Pick<ReturnType<typeof useMutation>, 'status' | 'error'>
  numTracks: number
  open: boolean
  setOpen: React.Dispatch<React.SetStateAction<boolean>>
  currentView: ViewVariant
  setCurrentView: React.Dispatch<React.SetStateAction<ViewVariant>>
}

export const WelcomeModalContext =
  React.createContext<WelcomeModalContextProps>({
    closeModal: {
      handleCloseModal: () => null,
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
  endpoint,
  numTracks,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
  numTracks: number
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const [currentView, setCurrentView] = useState<ViewVariant>('initial')

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(
    () => {
      const { fetch } = sendRequest({
        // close modal endpoint
        endpoint,
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

  const handleCloseModal = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <WelcomeModalContext.Provider
      value={{
        closeModal: {
          handleCloseModal,
          status,
          error,
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
