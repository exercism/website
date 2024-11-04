import React, { useCallback, useState } from 'react'
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

export default function SenioritySurveyModal({
  links,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  links: { hideModalEndpoint: string; apiUserEndpoint: string }
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const [selected, setSelected] = useState<SeniorityLevel | ''>('')
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

  const { mutate: setSeniorityMutation } = useMutation(
    (seniority: SeniorityLevel) => {
      const { fetch } = sendRequest({
        endpoint: links.apiUserEndpoint + `?user[seniority]=${seniority}`,
        method: 'PATCH',
        body: null,
      })

      return fetch
    }
  )

  const handleSave = useCallback(() => {
    if (selected === '') return
    setSeniorityMutation(selected)
    hideModalMutation()
  }, [selected, setSeniorityMutation, hideModalMutation])

  return (
    <Modal
      cover={true}
      open={open}
      {...props}
      style={{ content: { maxWidth: '620px' } }}
      onClose={() => null}
      className="m-welcome"
    >
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

        <p className="text-12 text-center mb-20">
          (This can be updated at any time in your settings)
        </p>
        <FormButton
          status={hideModalMutationStatus}
          disabled={selected === ''}
          className="btn-primary btn-l"
          type="button"
          onClick={handleSave}
        >
          Save my choice
        </FormButton>
        <ErrorBoundary resetKeys={[hideModalMutationStatus]}>
          <ErrorMessage
            error={hideModalMutationError}
            defaultError={DEFAULT_ERROR}
          />
        </ErrorBoundary>
      </div>
    </Modal>
  )
}
