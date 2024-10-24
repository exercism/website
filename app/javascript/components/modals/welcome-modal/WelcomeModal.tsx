import React, { useContext, useState } from 'react'
import { Modal, ModalProps } from '../Modal'
import { InitialView } from './InitialView'
import { SeniorView } from './SeniorView'
import { JuniorView } from './JuniorView'

export const VIEW_CHANGER_BUTTON_CLASS =
  'cursor-pointer text-18 font-semibold rounded-8 border-1 border-borderColor1 px-12 py-8 h-[56px]'

type ViewVariant = 'initial' | 'junior' | 'senior'

type WelcomeModalContextProps = {
  endpoint: string
  numTracks: number
  open: boolean
  setOpen: React.Dispatch<React.SetStateAction<boolean>>
  currentView: ViewVariant
  setCurrentView: React.Dispatch<React.SetStateAction<ViewVariant>>
}

export const WelcomeModalContext =
  React.createContext<WelcomeModalContextProps>({
    endpoint: '',
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

  return (
    <WelcomeModalContext.Provider
      value={{
        endpoint,
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
    case 'junior':
      return <JuniorView />
    case 'senior':
      return <SeniorView />
    default:
      return null
  }
}
