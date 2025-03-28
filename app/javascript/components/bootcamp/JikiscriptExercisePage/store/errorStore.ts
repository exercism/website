import { createStoreWithMiddlewares } from './utils'

type ErrorStore = {
  hasUnhandledError: boolean
  setHasUnhandledError: (hasUnhandledMountingError: boolean) => void
  unhandledErrorBase64: string
  setUnhandledErrorBase64: (unhandledErrorBase64: string) => void
  cleanUpErrorStore: () => void
}

const useErrorStore = createStoreWithMiddlewares<ErrorStore>(
  (set) => ({
    hasUnhandledError: false,
    setHasUnhandledError: (hasUnhandledError) =>
      set({ hasUnhandledError }, false, 'editor/setHasUnhandledError'),
    unhandledErrorBase64: '',
    setUnhandledErrorBase64: (unhandledMountingErrorBase64) =>
      set(
        {
          unhandledErrorBase64: btoa(unhandledMountingErrorBase64),
        },
        false,
        'editor/setUnhandledErrorBase64'
      ),
    cleanUpErrorStore: () => {
      set(
        {
          hasUnhandledError: false,
          unhandledErrorBase64: '',
        },
        false,
        'editor/cleanUpErrorStore'
      )
    },
  }),
  'ErrorStore'
)

export default useErrorStore
