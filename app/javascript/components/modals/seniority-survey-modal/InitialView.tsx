import React, { useContext, useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { SenioritySurveyModalContext } from './SenioritySurveyModal'
import type { SeniorityLevel } from '../welcome-modal/WelcomeModal'
import { ErrorFallback } from '@/components/common/ErrorFallback'

const DEFAULT_ERROR = new Error('Unable to save seniority level.')

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

export function InitialView() {
  const { links, setCurrentView, patchCloseModal } = useContext(
    SenioritySurveyModalContext
  )
  const [selected, setSelected] = useState<SeniorityLevel | ''>('')

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
    onSuccess: () => {
      if (selected.includes('beginner')) {
        setCurrentView('bootcamp-advertisment')
        return
      }

      patchCloseModal.mutate()
    },
  })

  const handleSaveSeniorityLevel = useCallback(() => {
    if (selected === '') return
    setSeniorityMutation(selected)
  }, [selected, setSeniorityMutation])

  return (
    <div className="lhs">
      <header>
        <h1>Hey there 👋</h1>
        <p className="mb-16">
          We're expanding Exercism to add content relevant to a wide range of
          abilities. To ensure Exercism shows you the right content, please tell
          us how experienced you are.
        </p>
        <h2>How experienced a developer are you?</h2>
      </header>
      <div className="flex flex-col flex-wrap gap-8 mb-16 text-18">
        {SENIORITIES.map((seniority) => (
          <button
            key={seniority.value}
            className={assembleClassNames(
              'btn-m btn-slightly-enhanced',
              selected === seniority.value
                ? 'border-prominentLinkColor text-prominentLinkColor'
                : ''
            )}
            onClick={() => setSelected(seniority.value)}
          >
            {seniority.label}
          </button>
        ))}
      </div>

      <FormButton
        status={setSeniorityMutationStatus}
        disabled={selected === ''}
        className="btn-primary btn-l w-100"
        type="button"
        onClick={handleSaveSeniorityLevel}
      >
        Save my choice
      </FormButton>
      <p className="text-14! text-center mt-12">
        (This can be updated at any time in your settings)
      </p>
      <ErrorBoundary
        FallbackComponent={ErrorFallback}
        resetKeys={[setSeniorityMutationStatus]}
      >
        <ErrorMessage
          error={setSeniorityMutationError}
          defaultError={DEFAULT_ERROR}
        />
      </ErrorBoundary>
      <ErrorBoundary resetKeys={[patchCloseModal.status]}>
        <ErrorMessage
          error={patchCloseModal.status}
          defaultError={DEFAULT_ERROR}
        />
      </ErrorBoundary>
    </div>
  )
}
