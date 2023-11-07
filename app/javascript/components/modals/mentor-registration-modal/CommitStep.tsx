import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Icon, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorMessage, ErrorBoundary } from '@/components/ErrorBoundary'
import { ReputationInfo } from './commit-step/ReputationInfo'
import { Checkbox } from './commit-step/Checkbox'

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
  } = useMutation(
    async () => {
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
    {
      onSuccess: () => {
        onContinue()
      },
    }
  )

  const [numChecked, setNumChecked] = useState(0)
  const handleChange = useCallback(
    (e) => {
      if (e.target.checked) {
        setNumChecked(numChecked + 1)
      } else {
        setNumChecked(numChecked - 1)
      }
    },
    [numChecked]
  )

  const handleSubmit = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <section className="commit-section">
      <div className="lhs">
        <h2>Commit to being a good mentor</h2>
        <p>
          Mentoring on Exercism can be an incredible experience for students and
          mentors alike. To ensure it remains a positive place for everyone, we
          ask all mentors to affirm Exercism&apos;s values before they mentor
          their first solution.
        </p>
        <ReputationInfo />
        <div className="commitment">
          <h3>You agree to:</h3>
          <Checkbox onChange={handleChange}>
            <span>
              Abide by the{' '}
              <a href={links.codeOfConduct} target="_blank" rel="noreferrer">
                Code of Conduct{' '}
                <Icon icon="external-link" alt="Opens in a new tab" />
              </a>
            </span>
          </Checkbox>
          <Checkbox onChange={handleChange}>
            <span>
              Be patient, empathic and kind to those you&apos;re mentoring
            </span>
          </Checkbox>
          <Checkbox onChange={handleChange}>
            <span>
              Demonstrate{' '}
              <a
                href={links.intellectualHumility}
                target="_blank"
                rel="noreferrer"
              >
                intellectual humility{' '}
                <Icon icon="external-link" alt="Opens in a new tab" />
              </a>
            </span>
          </Checkbox>
          <Checkbox onChange={handleChange}>
            <span>Not use Exercism to promote personal agendas</span>
          </Checkbox>
        </div>

        <div className="flex">
          <FormButton
            onClick={onBack}
            status={status}
            className="btn-default btn-m mr-16"
          >
            Back
          </FormButton>
          <FormButton
            className="btn-primary btn-m"
            onClick={handleSubmit}
            status={status}
            disabled={numChecked !== NUM_TO_CHECK}
          >
            <span>Continue</span>
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
