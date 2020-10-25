export type ConceptStatus = 'locked' | 'unlocked' | 'completed' | 'in_progress'

export interface IConcept {
  slug: string
  web_url: string
  name: string
}

export function isIConcept(concept: IConcept | undefined): concept is IConcept {
  return concept !== undefined
}

export type ConceptConnection = {
  from: string
  to: string
}

export type ConceptPathStatus = 'locked' | 'available' | 'complete'

export type ConceptPathCoordinate = {
  x: number
  y: number
}

export type ConceptPath = {
  start: ConceptPathCoordinate
  end: ConceptPathCoordinate
  status: ConceptPathStatus
}

export function isConceptPath(
  conceptPath: ConceptPath | undefined
): conceptPath is ConceptPath {
  return conceptPath !== undefined
}

export interface IConceptMap {
  concepts: IConcept[]
  levels: ConceptLayer[]
  connections: ConceptConnection[]
  status: { [key: string]: ConceptStatus }
}

export type ConceptLayer = string[]
