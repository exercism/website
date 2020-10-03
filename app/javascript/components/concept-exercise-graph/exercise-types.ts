import { MouseEventHandler } from 'react'

export enum ExerciseState {
  Locked = 'locked',
  Unlocked = 'unlocked',
  Completed = 'completed',
  InProgress = 'in_progress',
}

export type Exercise = {
  index: number
  slug: string
  uuid: string
  concepts: string[]
  prerequisites: string[]
  status: ExerciseState
  handleEnter?: MouseEventHandler
  handleLeave?: MouseEventHandler
}

export type ExerciseLayer = string[]

export type ExerciseConnection = {
  from: string
  to: string
}

export interface ExerciseGraph {
  exercises: Exercise[]
  layout: ExerciseLayer[]
  connections: ExerciseConnection[]
}
