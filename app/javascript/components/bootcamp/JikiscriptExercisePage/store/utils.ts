import { create } from 'zustand'
import { devtools } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'
// TODO: Fix this, move this to global declaration file
import type { StateWithMiddleware, StateSetter } from './types'

// TODO: Typing this is insanely complicated. Reduce complexity.

export function createStoreWithMiddlewares<State>(
  config: (set: StateSetter<State>, get: () => State, api: any) => State,

  storeName: string
) {
  return create<State, StateWithMiddleware>(
    devtools(immer(config), { name: storeName })
  )
}

export function createSetter<State, Key extends keyof State>(
  set: (
    updater: (state: State) => void,
    replace?: boolean,
    actionName?: string
  ) => void,
  key: Key
) {
  return (input: State[Key] | ((draft: State[Key]) => State[Key])) =>
    set(
      (state) => {
        if (typeof input === 'function') {
          state[key] = (input as Function)(state[key])
        } else {
          state[key] = input
        }
      },
      false,
      `exercise/set${capitalize(String(key))}`
    )
}

function capitalize(str: string): string {
  if (!str) return str
  return str.charAt(0).toUpperCase() + str.slice(1)
}
