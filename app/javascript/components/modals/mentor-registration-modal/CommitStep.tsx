import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Icon, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorMessage, ErrorBoundary } from '@/components/ErrorBoundary'
import { ReputationInfo } from './commit-step/ReputationInfo'
import { Checkbox } from './commit-step/Checkbox'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export type Links = {
  codeOfConduct: string
  intellectualHumility: string
  registration: string
}

const NUM_TO_CHECK = 4
const DEFAULT_ERROR = new Error('Unable to complete registration')

export const CommitStep = ({
  links,
  selected,
  onContinue,
  onBack,
}: {
  links: Links
  selected: string[]
  onContinue: () => void
  onBack: () => void
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: links.registration,
        method: 'POST',
        body: JSON.stringify({
          track_slugs: selected,
          accept_terms: true,
        }),
      })
      return fetch
    },
    onSuccess: () => {
      onContinue()
    },
  })

  const { t } = useAppTranslation('components/modals/mentor-registration-modal')

  const [numChecked, setNumChecked] = useState(0)
  const handleChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const { checked } = e.target
    setNumChecked((prev) => (checked ? prev + 1 : prev - 1))
  }, [])

  const handleSubmit = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <section className="commit-section">
      <div className="lhs">
        <h2>{t('commitStep.title')}</h2>
        <p>{t('commitStep.description')}</p>
        <ReputationInfo />

        <div className="commitment">
          <h3>{t('commitStep.youAgreeTo')}</h3>

          <Checkbox onChange={handleChange}>
            <span>
              <Trans
                ns="components/modals/mentor-registration-modal"
                i18nKey="commitStep.codeOfConduct"
                components={[
                  <a
                    key="link"
                    href={links.codeOfConduct}
                    target="_blank"
                    rel="noreferrer"
                  />,
                  <Icon
                    key="icon"
                    icon="external-link"
                    alt="Opens in a new tab"
                  />,
                ]}
              />
            </span>
          </Checkbox>

          <Checkbox onChange={handleChange}>
            <span>{t('commitStep.beKind')}</span>
          </Checkbox>

          <Checkbox onChange={handleChange}>
            <span>
              <Trans
                ns="components/modals/mentor-registration-modal"
                i18nKey="commitStep.intellectualHumility"
                components={[
                  <a
                    key="link"
                    href={links.intellectualHumility}
                    target="_blank"
                    rel="noreferrer"
                  />,
                  <Icon
                    key="icon"
                    icon="external-link"
                    alt="Opens in a new tab"
                  />,
                ]}
              />
            </span>
          </Checkbox>

          <Checkbox onChange={handleChange}>
            <span>{t('commitStep.noAgendas')}</span>
          </Checkbox>
        </div>

        <div className="flex">
          <FormButton
            onClick={onBack}
            status={status}
            className="btn-default btn-m mr-16"
          >
            {t('commitStep.back')}
          </FormButton>
          <FormButton
            className="btn-primary btn-m"
            onClick={handleSubmit}
            status={status}
            disabled={numChecked !== NUM_TO_CHECK}
          >
            <span>{t('commitStep.continue')}</span>
            <GraphicalIcon icon="arrow-right" />
          </FormButton>
        </div>

        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </div>

      <div className="rhs">
        <GraphicalIcon icon="mentoring-screen" category="graphics" />
      </div>
    </section>
  )
}
