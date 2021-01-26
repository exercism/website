import React from 'react'
import { ConceptIcon } from '../../common/ConceptIcon'

export const UnlockedConcept = ({ name }: { name: string }): JSX.Element => {
  return (
    <div className="concept">
      <ConceptIcon name={name} size="small" />
      <div className="title">{name}</div>
    </div>
  )
}
