import React, {
  createContext,
  Dispatch,
  SetStateAction,
  useContext,
  useState,
} from 'react'
import { Modal, ModalProps } from '../Modal'
import { ThanksView } from './ThanksView'
import { InitialView } from './InitialView'

type ViewVariant = 'initial' | 'thanks'

type Links = { hideModalEndpoint: string; apiUserEndpoint: string }

type SenioritySurveyModalContextProps = {
  currentView: ViewVariant
  setCurrentView: Dispatch<SetStateAction<ViewVariant>>
  setOpen: Dispatch<SetStateAction<boolean>>
  links: Links
}

const DEFAULT_VIEW = 'thanks'

export const SenioritySurveyModalContext =
  createContext<SenioritySurveyModalContextProps>({
    currentView: DEFAULT_VIEW,
    setCurrentView: () => {},
    setOpen: () => {},
    links: { apiUserEndpoint: '', hideModalEndpoint: '' },
  })

export default function SenioritySurveyModal({
  links,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(true)

  const [currentView, setCurrentView] = useState<ViewVariant>(DEFAULT_VIEW)

  return (
    <SenioritySurveyModalContext.Provider
      value={{ currentView, setCurrentView, setOpen, links }}
    >
      <Modal
        cover={true}
        open={open}
        {...props}
        style={{ content: { maxWidth: '620px' } }}
        onClose={() => null}
        className="m-welcome"
      >
        <Inner />
      </Modal>
    </SenioritySurveyModalContext.Provider>
  )
}

function Inner() {
  const { currentView } = useContext(SenioritySurveyModalContext)
  switch (currentView) {
    case 'initial':
      return <InitialView />
    case 'thanks':
      return <ThanksView />
  }
}
