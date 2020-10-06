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

export function isIConcept(concept: IConcept | undefined): concept is IConcept {
  return concept !== undefined
}
