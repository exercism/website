import React, { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'
import { assembleClassNames } from '@/utils/assemble-classnames'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

const SENIORITIES = [
  'beginner',
  'junior',
  'medior',
  'senior',
  'staff',
  'lead',
] as const
type Seniority = typeof SENIORITIES[number] | ''

export default function SenioritySurveyModal({
  endpoint,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const [selected, setSelected] = useState<Seniority>('')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
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

  const handleClick = useCallback(() => {
    mutation()
  }, [mutation])

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
                selected === seniority
                  ? 'border-prominentLinkColor text-prominentLinkColor'
                  : 'border-borderColor1'
              )}
              onClick={() => setSelected(seniority)}
            >
              {seniority}
            </button>
          ))}
        </div>

        <p className="text-14 text-center mt-4">
          (This can be updated at any time in your settings)
        </p>
        <FormButton
          status={status}
          className="btn-primary btn-l"
          type="button"
          onClick={handleClick}
        >
          Save my choice
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </div>
    </Modal>
  )
}
