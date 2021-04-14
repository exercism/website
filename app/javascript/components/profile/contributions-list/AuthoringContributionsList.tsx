import React from 'react'
import { ExerciseWidget } from '../../common'
import { ExerciseAuthorship } from '../../types'

export const AuthoringContributionsList = ({
  authorships,
}: {
  authorships: readonly ExerciseAuthorship[]
}): JSX.Element => {
  return (
    <div className="authoring">
      <div className="exercises">
        {authorships.map((authorship) => {
          return (
            <ExerciseWidget
              key={authorship.exercise.slug}
              exercise={authorship.exercise}
              track={authorship.track}
              size="large"
            />
          )
        })}
      </div>
    </div>
  )
}
