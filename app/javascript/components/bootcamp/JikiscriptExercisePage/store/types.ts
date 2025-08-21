import type { Draft } from 'immer'

export type StateWithMiddleware = [
  ['zustand/devtools', never],
  ['zustand/immer', never]
]

export type CreatedSetter<T> = (
  value: T | Draft<T> | ((draft: Draft<T>) => T | Draft<T>)
) => void

export type StateSetter<Store> = (
  nextStateOrUpdater: Store | Partial<Store> | ((state: Draft<Store>) => void),
  shouldReplace?: boolean | undefined,
  action?: string | undefined
) => void
