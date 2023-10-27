import React from 'react'
import { ConceptIcon } from '../../../common/ConceptIcon'
import { Concept } from '../../CompleteExerciseModal'

export const UnlockedConcept = ({ name, links }: Concept): JSX.Element => {
  return (
    <a href={links.self} className="c-unlocked-concept">
      <ConceptIcon name={name} size="small" />
      <div className="name">{name}</div>
    </a>
  )
}
