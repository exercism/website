export type ConceptStatus = 'locked' | 'available' | 'learned' | 'mastered'

export type ExerciseStatus = 'locked' | 'available' | 'in-progress' | 'complete'

export interface IConcept {
  slug: string
  webUrl: string
  tooltipUrl: string
  name: string
  exercises: {
    conceptExercises: string[]
    practiceExercises: string[]
  }
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
export type ExerciseStatusIndex = { [key: string]: ExerciseStatus }

export interface IConceptMap {
  concepts: IConcept[]
  levels: ConceptLayer[]
  connections: ConceptConnection[]
  status: ConceptStatusIndex
  exerciseStatus: ExerciseStatusIndex
  exercises: {
    [key: string]: {
      conceptExercises: string[]
      practiceExercises: string[]
    }
  }
}

export type ConceptLayer = string[]
