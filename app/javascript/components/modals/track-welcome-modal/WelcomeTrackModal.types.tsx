import { State, ResolveTypegenMeta, BaseActionObject, ServiceMap } from 'xstate'
import { StateEvent } from './LHS/lhs.machine'
import { Typegen0 } from './LHS/lhs.machine.typegen'
import { Track } from '@/components/types'

export type TrackWelcomeModalProps = {
  links: Record<
    | 'hideModal'
    | 'activatePracticeMode'
    | 'activateLearningMode'
    | 'helloWorld',
    string
  >
  track: Track
}

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
