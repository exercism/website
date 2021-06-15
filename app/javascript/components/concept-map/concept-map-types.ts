import { ExerciseStatus } from '../types'

export type ConceptStatus = 'locked' | 'available' | 'learned' | 'mastered'

export interface IConcept {
  slug: string
  webUrl: string
  tooltipUrl: string
  name: string
}

export function isIConcept(concept: IConcept | undefined): concept is IConcept {
  return concept !== undefined
}

export type ConceptConnection = {
  from: string
  to: string
}

export type ConceptPathStatus = 'locked' | 'unlocked'

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

export type ConceptStatusIndex = { [key: string]: ConceptStatus }
export type ExercisesDataIndex = { [key: string]: ExerciseData[] }

export interface IConceptMap {
  concepts: IConcept[]
  levels: ConceptLayer[]
  connections: ConceptConnection[]
  status: ConceptStatusIndex
  exercisesData: ExercisesDataIndex
}

export type ConceptLayer = string[]

export type ExerciseData = {
  url: string
  slug: string
  tooltipUrl: string
  status: ExerciseStatus
  type: string
}
