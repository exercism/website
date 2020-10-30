export type ConceptStatus = 'available' | 'unavailable'

export interface IConcept {
  slug: string
  web_url: string
  name: string
  exercises?: number
  completedExercises?: number
}

export function isIConcept(concept: IConcept | undefined): concept is IConcept {
  return concept !== undefined
}

export type ConceptConnection = {
  from: string
  to: string
}

export type ConceptPathStatus = 'available' | 'unavailable'

export type ConceptPathCoordinate = {
  x: number
  y: number
}

export type PathCourse =
  | 'left'
  | 'center-left'
  | 'center'
  | 'center-right'
  | 'right'

export type ConceptPathProperties = {
  width: number
  height: number
  radius: number
  translateX: number
  translateY: number
  pathStart: ConceptPathCoordinate
  pathEnd: ConceptPathCoordinate
  status: ConceptPathStatus
  pathCourse: PathCourse
}

export function isConceptPathProperties(
  props: ConceptPathProperties | undefined
): props is ConceptPathProperties {
  return props !== undefined
}

export interface IConceptMap {
  concepts: IConcept[]
  levels: ConceptLayer[]
  connections: ConceptConnection[]
  status: { [key: string]: ConceptStatus }
  exerciseCounts: {
    [key: string]: { exercises: number; completedExercises: number }
  }
}

export type ConceptLayer = string[]
