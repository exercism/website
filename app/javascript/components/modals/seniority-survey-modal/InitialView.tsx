import React, { useContext, useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { SenioritySurveyModalContext } from './SenioritySurveyModal'
import type { SeniorityLevel } from '../welcome-modal/WelcomeModal'

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
