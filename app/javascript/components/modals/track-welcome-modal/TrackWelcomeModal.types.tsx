import { State, ResolveTypegenMeta, BaseActionObject, ServiceMap } from 'xstate'
import { StateEvent } from './LHS/TrackWelcomeModal.machine'
import { Typegen0 } from './LHS/TrackWelcomeModal.machine.typegen'
import { Track } from '@/components/types'

export type TrackWelcomeModalProps = {
  track: Track
  links: TrackWelcomeModalLinks
}

export type TrackWelcomeModalLinks = Record<
  | 'hideModal'
  | 'activatePracticeMode'
  | 'activateLearningMode'
  | 'editHelloWorld'
  | 'cliWalkthrough'
  | 'trackTooling'
  | 'learningResources',
  string
>

export type CurrentState = State<
  {
    choices: {
      Mode: string
      Interface: string
    }
  },
  {
    type: StateEvent
  },
  any,
  {
    value: any
    context: {
      choices: {
        Mode: string
        Interface: string
      }
    }
  },
  ResolveTypegenMeta<
    Typegen0,
    {
      type: StateEvent
    },
    BaseActionObject,
    ServiceMap
  >
>
