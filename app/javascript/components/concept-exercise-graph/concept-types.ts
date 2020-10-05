import { MouseEventHandler } from 'react'

export enum ConceptState {
  Locked = 'locked',
  Unlocked = 'unlocked',
  Completed = 'completed',
  InProgress = 'in_progress',
}

export interface IExercise {
  slug: string
  uuid: string
  prerequisiteConcepts: string[]
  unlocksConcepts: string[]
}

export interface IConcept {
  index: number
  slug: string
  conceptExercise: string
  web_url: string
  status: ConceptState
  handleEnter?: MouseEventHandler
  handleLeave?: MouseEventHandler
}

export type ConceptLayer = string[]

export type ConceptConnection = {
  from: string
  to: string
}

export interface IConceptGraph {
  concepts: IConcept[]
  layout: ConceptLayer[]
  connections: ConceptConnection[]
}
