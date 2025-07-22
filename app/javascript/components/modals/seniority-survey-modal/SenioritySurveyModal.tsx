// i18n-key-prefix: senioritySurveyModal
// i18n-namespace: components/modals/seniority-survey-modal
import React, {
  createContext,
  Dispatch,
  SetStateAction,
  useContext,
  useState,
} from 'react'
import { Modal, ModalProps } from '../Modal'
import { InitialView } from './InitialView'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { BootcampAdvertismentView } from './BootcampAdvertismentView'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type ViewVariant = 'initial' | 'thanks' | 'bootcamp-advertisment'

type Links = {
  hideModalEndpoint: string
  apiUserEndpoint: string
  codingFundamentalsCourse: string
}

type SenioritySurveyModalContextProps = {
  currentView: ViewVariant
  setCurrentView: Dispatch<SetStateAction<ViewVariant>>
  setOpen: Dispatch<SetStateAction<boolean>>
  links: Links
  patchCloseModal: {
    mutate: () => void
  } & Pick<ReturnType<typeof useMutation>, 'status' | 'error'>
}

const DEFAULT_VIEW = 'initial'

export const SenioritySurveyModalContext =
  createContext<SenioritySurveyModalContextProps>({
    currentView: DEFAULT_VIEW,
    setCurrentView: () => {},
    setOpen: () => {},
    links: {
      apiUserEndpoint: '',
      hideModalEndpoint: '',
      codingFundamentalsCourse: '',
    },
    patchCloseModal: {
      mutate: () => null,
      status: 'idle',
      error: null,
    },
  })

export default function SenioritySurveyModal({
  links,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/modals/seniority-survey-modal')
  const [open, setOpen] = useState(true)
  const [currentView, setCurrentView] = useState<ViewVariant>(DEFAULT_VIEW)

  const {
    mutate: hideModalMutation,
    status: hideModalMutationStatus,
    error: hideModalMutationError,
  } = useMutation({
    mutationFn: () => {
      const { fetch } = sendRequest({
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

  return (
    <SenioritySurveyModalContext.Provider
      value={{
        currentView,
        setCurrentView,
        setOpen,
        links,
        patchCloseModal: {
          mutate: hideModalMutation,
          status: hideModalMutationStatus,
          error: hideModalMutationError,
        },
      }}
    >
      <Modal
        cover={true}
        open={open}
        {...props}
        style={{
          content: {
            maxWidth: currentView === 'bootcamp-advertisment' ? '' : '620px',
            placeSelf: 'center',
          },
        }}
        onClose={() => null}
        className="m-welcome"
      >
        <Inner />
      </Modal>
    </SenioritySurveyModalContext.Provider>
  )
}

function Inner() {
  const { t } = useAppTranslation('components/modals/seniority-survey-modal')
  const { currentView } = useContext(SenioritySurveyModalContext)
  switch (currentView) {
    case 'initial':
      return <InitialView />
    case 'bootcamp-advertisment':
      return <BootcampAdvertismentView />
  }
}
