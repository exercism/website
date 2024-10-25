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
      onClose={() => null}
      className="m-welcome"
    >
      {' '}
      <div className="lhs">
        {' '}
        <header>
          {' '}
          <h1>Hey!</h1>{' '}
          <p className="mb-16">
            We're starting to add more features and nudges and want to ensure
            they're relevant to you.
          </p>
          <h2>What seniority are you?</h2>
        </header>
        <div className="flex flex-row flex-wrap gap-8 mb-16 text-18">
          {SENIORITIES.map((seniority) => (
            <button
              className={assembleClassNames(
                'p-8 border-1 rounded-8 font-medium',
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
