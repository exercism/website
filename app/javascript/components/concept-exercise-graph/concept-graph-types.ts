import { IConcept } from './concept-types'
import { ConceptConnection } from './concept-connection-types'

export interface IConceptGraph {
  concepts: IConcept[]
  layout: ConceptLayer[]
  connections: ConceptConnection[]
}

export type ConceptLayer = string[]

export interface IExercise {
  slug: string
  uuid: string
  prerequisiteConcepts: string[]
  unlocksConcepts: string[]
}
