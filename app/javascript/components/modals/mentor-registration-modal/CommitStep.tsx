import React, { useState, useCallback } from 'react'
import { Icon, GraphicalIcon } from '../../common'
import { ReputationInfo } from './commit-step/ReputationInfo'
import { Checkbox } from './commit-step/Checkbox'
import { FormButton } from './commit-step/FormButton'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { ErrorMessage, ErrorBoundary } from '../../ErrorBoundary'

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
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: links.registration,
        method: 'POST',
        body: JSON.stringify({
          track_ids: selected,
          accept_terms: true,
        }),
        isMountedRef: isMountedRef,
      })
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
          ask all mentors to affirm Exercism&apos;s values before then mentor
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
        {/*TODO: Style this */}
        <FormButton onClick={onBack} status={status}>
          Back
        </FormButton>
        <FormButton
          className="btn-cta"
          onClick={handleSubmit}
          status={status}
          disabled={numChecked !== NUM_TO_CHECK}
        >
          <span>Continue</span>
          <GraphicalIcon icon="arrow-right" />
        </FormButton>
        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </div>
      <div className="rhs">
        <GraphicalIcon icon="graphic-mentoring-screen" />
      </div>
    </section>
  )
}
