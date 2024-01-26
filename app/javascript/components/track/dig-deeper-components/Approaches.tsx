import React, { useContext } from 'react'
import { ApproachSnippet, SectionHeader } from '.'
import { Approach, DigDeeperDataContext } from '../DigDeeper'

export function Approaches({
  approaches,
}: {
  approaches: Approach[]
}): JSX.Element {
  const { exercise } = useContext(DigDeeperDataContext)
  return (
    <div className="lg:flex lg:flex-col mb-24">
      <SectionHeader
        title="Approaches"
        description={
          approaches.length > 0
            ? 'Other ways our community solved this exercise'
            : `There are no Approaches for ${exercise.title}.`
        }
        icon="dig-deeper-gradient"
        className="mb-16"
      />

      <div className="lg:flex lg:flex-col grid grid-cols-1 md:grid-cols-2 gap-x-16 lg:gap-x-[unset]">
        {approaches.length > 0 &&
          approaches.map((i) => {
            return <ApproachSnippet key={i.title} approach={i} />
          })}
      </div>
    </div>
  )
}
