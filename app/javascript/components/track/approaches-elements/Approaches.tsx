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
    <div className="flex flex-col">
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

      {approaches.length > 0 &&
        approaches.map((i) => {
          return <ApproachSnippet key={i.title} approach={i} />
        })}
    </div>
  )
}
