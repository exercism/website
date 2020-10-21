import { MouseEventHandler } from 'react'

export enum ConceptState {
  Locked = 'locked',
  Unlocked = 'unlocked',
  Completed = 'completed',
  InProgress = 'in_progress',
}

export interface IConcept {
  slug: string
  web_url: string
  name: string
  handleEnter?: MouseEventHandler
  handleLeave?: MouseEventHandler
}

export function isIConcept(concept: IConcept | undefined): concept is IConcept {
  return concept !== undefined
}
