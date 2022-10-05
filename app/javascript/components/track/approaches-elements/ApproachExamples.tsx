import React, { useContext } from 'react'
import { NoContentYet, SectionHeader } from '.'
import { ApproachesDataContext } from '../Approaches'

export function ApproachExamples(): JSX.Element {
  const { exercise } = useContext(ApproachesDataContext)
  return (
    <div className="flex flex-col">
      <SectionHeader
        title="Approaches"
        description="Other ways our community solved this exercise"
        icon="dig-deeper-gradient"
        className="mb-16"
      />

      <NoContentYet exerciseTitle={exercise.title} contentType={'Approaches'} />
    </div>
  )
}
