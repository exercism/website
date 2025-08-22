// i18n-key-prefix: initialView
// i18n-namespace: components/modals/seniority-survey-modal
import React, { useContext, useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { SenioritySurveyModalContext } from './SenioritySurveyModal'
import type { SeniorityLevel } from '../welcome-modal/WelcomeModal'
import { ErrorFallback } from '@/components/common/ErrorFallback'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to save seniority level.')

export const SENIORITIES: {
  key: string
  label: string
  value: SeniorityLevel
}[] = [
  {
    key: 'absoluteBeginner',
    label: 'Absolute Beginner',
    value: 'absolute_beginner',
  },
  {
    key: 'beginner',
    label: 'Beginner',
    value: 'beginner',
  },
  {
    key: 'juniorDeveloper',
    label: 'Junior Developer',
    value: 'junior',
  },
  {
    key: 'midLevelDeveloper',
    label: 'Mid-level Developer',
    value: 'mid',
  },
  {
    key: 'seniorDeveloper',
    label: 'Senior Developer',
    value: 'senior',
  },
]

export function InitialView() {
  const { t } = useAppTranslation('components/modals/seniority-survey-modal')
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
        <h1>{t('initialView.heyThere')}</h1>
        <p className="mb-16">{t('initialView.expandingExercism')}</p>
        <h2>{t('initialView.howExperiencedAreYou')}</h2>
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
            {t(`initialView.${seniority.key}`)}
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
        {t('initialView.saveMyChoice')}
      </FormButton>
      <p className="!text-14 text-center mt-12">
        {t('initialView.canBeUpdatedInSettings')}
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
