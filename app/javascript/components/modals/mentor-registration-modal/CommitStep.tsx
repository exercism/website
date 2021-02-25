import React, { useState, useCallback } from 'react'
import { Icon, GraphicalIcon } from '../../common'
import { ReputationInfo } from './commit-step/ReputationInfo'
import { Checkbox } from './commit-step/Checkbox'

export type Links = {
  codeOfConduct: string
  intellectualHumility: string
}

const NUM_TO_CHECK = 4

export const CommitStep = ({ links }: { links: Links }): JSX.Element => {
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
        <button className="btn-cta" disabled={numChecked !== NUM_TO_CHECK}>
          <span>Continue</span>
          <GraphicalIcon icon="arrow-right" />
        </button>
      </div>
      <div className="rhs">
        <GraphicalIcon icon="graphic-mentoring-screen" />
      </div>
    </section>
  )
}
