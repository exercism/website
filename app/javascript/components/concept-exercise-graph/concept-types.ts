import { MouseEventHandler } from 'react'

export enum ConceptState {
  Locked = 'locked',
  Unlocked = 'unlocked',
  Completed = 'completed',
  InProgress = 'in_progress',
}

export interface IConcept {
  index: number
  slug: string
  web_url: string
  status: ConceptState
  handleEnter?: MouseEventHandler
  handleLeave?: MouseEventHandler
}

export function isIConcept(concept: IConcept | undefined): concept is IConcept {
  return concept !== undefined
}
