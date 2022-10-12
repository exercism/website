import React, { useContext } from 'react'
import { SectionHeader } from '.'
import { ApproachesDataContext } from '../Approaches'

export function ApproachExamples(): JSX.Element {
  const { exercise } = useContext(ApproachesDataContext)
  return (
    <div className="flex flex-col">
      <SectionHeader
        title="Approaches"
        description={`There are no Approaches for ${exercise.title}.`}
        icon="dig-deeper-gradient"
        className="mb-16"
      />
    </div>
  )
}
