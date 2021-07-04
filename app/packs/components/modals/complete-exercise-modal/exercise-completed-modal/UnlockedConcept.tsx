import React from 'react'
import { ConceptIcon } from '../../../common/ConceptIcon'
import { Concept } from '../../CompleteExerciseModal'

export const UnlockedConcept = ({ name }: Concept): JSX.Element => {
  return (
    <div className="unlocked-concept">
      <ConceptIcon name={name} size="small" />
      <div className="name">{name}</div>
    </div>
  )
}
