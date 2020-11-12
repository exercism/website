export type ConceptStatus = 'available' | 'unavailable' | 'completed'

export interface IConcept {
  slug: string
  web_url: string
  tooltip_url: string
  name: string
  exercises?: number
  exercisesCompleted?: number
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
  exercise_counts: {
    [key: string]: { exercises: number; exercises_completed: number }
  }
}

export type ConceptLayer = string[]
