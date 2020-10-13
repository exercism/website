import { IConcept } from './concept-types'
import { ConceptConnection } from './concept-connection-types'

export interface IConceptMap {
  concepts: IConcept[]
  levels: ConceptLayer[]
  connections: ConceptConnection[]
}

export type ConceptLayer = string[]

export interface IExercise {
  slug: string
  uuid: string
  prerequisiteConcepts: string[]
  unlocksConcepts: string[]
}
