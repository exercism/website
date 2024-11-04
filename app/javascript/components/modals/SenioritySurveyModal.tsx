import React, {
  createContext,
  Dispatch,
  SetStateAction,
  useCallback,
  useContext,
  useState,
} from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { SeniorityLevel } from './welcome-modal/WelcomeModal'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

const SENIORITIES: { label: string; value: SeniorityLevel }[] = [
  {
    label: 'Absolute Beginner',
    value: 'absolute_beginner',
  },
  {
    label: 'Beginner',
    value: 'beginner',
  },
  {
    label: 'Junior Developer',
    value: 'junior',
  },
  {
    label: 'Mid-level Developer',
    value: 'mid',
  },
  {
    label: 'Senior Developer',
    value: 'senior',
  },
]

type ViewVariant = 'initial' | 'thanks'

type Links = { hideModalEndpoint: string; apiUserEndpoint: string }

type SenioritySurveyModalContextProps = {
  currentView: ViewVariant
  setCurrentView: Dispatch<SetStateAction<ViewVariant>>
  setOpen: Dispatch<SetStateAction<boolean>>
  links: Links
}

const DEFAULT_VIEW = 'thanks'

const SenioritySurveyModalContext =
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
        <Inner currentView={currentView} />
      </Modal>
    </SenioritySurveyModalContext.Provider>
  )
}

function Inner({ currentView }: { currentView: ViewVariant }) {
  return currentView === 'initial' ? <SenioritySelectorView /> : <ThanksView />
}

function ThanksView() {
  const { links, setOpen } = useContext(SenioritySurveyModalContext)

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

  const handleSave = useCallback(() => {
    hideModalMutation()
  }, [hideModalMutation])
  return (
    <div className="lhs">
      <header>
        <h1>Thanks for letting us know!</h1>
        <p>
          We'll use this information to make sure you're seeing the most
          relevant content.
        </p>
      </header>

      <FormButton
        status={hideModalMutationStatus}
        className="btn-primary btn-l"
        type="button"
        onClick={handleSave}
      >
        Close this modal
      </FormButton>
      <ErrorBoundary resetKeys={[hideModalMutationStatus]}>
        <ErrorMessage
          error={hideModalMutationError}
          defaultError={DEFAULT_ERROR}
        />
      </ErrorBoundary>
    </div>
  )
}

function SenioritySelectorView() {
  const { links, setCurrentView } = useContext(SenioritySurveyModalContext)
  const [selected, setSelected] = useState<SeniorityLevel | ''>('')

  const {
    mutate: setSeniorityMutation,
    status: setSeniorityMutationStatus,
    error: setSeniorityMutationError,
  } = useMutation(
    (seniority: SeniorityLevel) => {
      const { fetch } = sendRequest({
        endpoint: links.apiUserEndpoint + `?user[seniority]=${seniority}`,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => setCurrentView('thanks'),
    }
  )

  const handleSaveSeniorityLevel = useCallback(() => {
    if (selected === '') return
    setSeniorityMutation(selected)
  }, [selected, setSeniorityMutation])

  return (
    <div className="lhs">
      <header>
        <h1>Hey there 👋</h1>
        <p className="mb-16">
          As Exercism grows, certain features are becoming more relevant than
          others based on your experience coding. So we're starting to filter
          what we show by your seniority.
        </p>
        <h2>How experienced a developer are you?</h2>
      </header>
      <div className="flex flex-col flex-wrap gap-8 mb-16 text-18">
        {SENIORITIES.map((seniority) => (
          <button
            className={assembleClassNames(
              'btn-m btn-enhanced',
              selected === seniority.value
                ? 'border-prominentLinkColor text-prominentLinkColor'
                : 'border-borderColor1'
            )}
            onClick={() => setSelected(seniority.value)}
          >
            {seniority.label}
          </button>
        ))}
      </div>

      <p className="!text-14 text-center mb-20">
        (This can be updated at any time in your settings)
      </p>
      <FormButton
        status={setSeniorityMutationStatus}
        disabled={selected === ''}
        className="btn-primary btn-l"
        type="button"
        onClick={handleSaveSeniorityLevel}
      >
        Save my choice
      </FormButton>
      <ErrorBoundary resetKeys={[setSeniorityMutationStatus]}>
        <ErrorMessage
          error={setSeniorityMutationError}
          defaultError={DEFAULT_ERROR}
        />
      </ErrorBoundary>
    </div>
  )
}
