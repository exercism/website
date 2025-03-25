import { create } from 'zustand'

export type AvailableCustomFunctions = Record<
  string,
  CustomFunctionForInterpreter & { dependsOnCurrentFunction?: boolean }
>

type CustomFunctionsStore = {
  /**
   * Cache of available custom functions that can be passed into the interpreter
   */
  availableCustomFunctions: AvailableCustomFunctions
  populateAvailableCustomFunctions: (
    customFunctions: CustomFunctionForInterpreter[]
  ) => void
  activateCustomFunction: (name: string) => void
  deactivateCustomFunction: (name: string) => void
  getIsFunctionActivated: (name: string) => boolean
  hasBeenInitialized: boolean
  initializeCustomFunctions: (
    customFunctions: CustomFunctionsFromServer
  ) => void
  activatedCustomFunctions: string[][]
  /**
   * Returns the list of functions the user clicked on - imported deliberately
   */
  getSelectedCustomFunctions: () => string[]
  setActivatedCustomFunctions: (activatedCustomFunctions: string[][]) => void
  customFunctionsForInterpreter: Record<string, CustomFunctionForInterpreter>
  populateCustomFunctionsForInterpreter: (
    customFunctionsForInterpreter: CustomFunctionForInterpreter[]
  ) => void
  addCustomFunctionsForInterpreter: (
    customFunctionsForInterpreter: CustomFunctionForInterpreter[]
  ) => void
  removeCustomFunctionForInterpreter: (name: string) => void
}

const useCustomFunctionStore = create<CustomFunctionsStore>((set, get) => ({
  hasBeenInitialized: false,
  initializeCustomFunctions: (customFunctions) => {
    const {
      hasBeenInitialized,
      populateAvailableCustomFunctions,
      activateCustomFunction,
    } = get()

    if (hasBeenInitialized) return

    populateAvailableCustomFunctions(customFunctions.forInterpreter)

    customFunctions.selected.forEach((fnName) => activateCustomFunction(fnName))
    set({ hasBeenInitialized: true })
  },
  availableCustomFunctions: {},
  populateAvailableCustomFunctions: (customFunctions) => {
    set(() => {
      const newAvailableCustomFunctions = customFunctions.reduce((acc, fn) => {
        acc[fn.name] = fn
        return acc
      }, {})

      return {
        availableCustomFunctions: newAvailableCustomFunctions,
      }
    })
  },
  activatedCustomFunctions: [],
  getSelectedCustomFunctions: () => {
    const activatedCustomFunctions = get().activatedCustomFunctions
    const selectedCustomFunctions = new Set(
      activatedCustomFunctions.map((fn) => fn[0])
    )
    return Array.from(selectedCustomFunctions)
  },
  setActivatedCustomFunctions: (activatedCustomFunctions: string[][]) => {
    set({ activatedCustomFunctions })
  },
  addActivatedCustomFunction: (linkedFunctions: string[]) => {
    set((state) => {
      const activatedCustomFunctions = [
        ...state.activatedCustomFunctions,
        linkedFunctions,
      ]
      return {
        activatedCustomFunctions,
      }
    })
  },
  removeActivatedCustomFunction: (name: string) => {
    set((state) => {
      const activatedCustomFunctions = state.activatedCustomFunctions.filter(
        (fn) => fn[0] !== name
      )
      return {
        activatedCustomFunctions,
      }
    })
  },

  activateCustomFunction: async (name: string) => {
    const {
      activatedCustomFunctions,
      availableCustomFunctions,
      addCustomFunctionsForInterpreter,
    } = get()

    const customFunction = availableCustomFunctions[name]

    const dependencies = customFunction.dependencies
    const linkedFunctions = [name, ...dependencies]
    const newActivatedCustomFunctions = [
      ...activatedCustomFunctions,
      linkedFunctions,
    ]

    // we collect functions from the cache by going through the relation array
    const customFunctionsToBeAddedToTheInterpreter = linkedFunctions.map(
      (fn) => {
        return get().availableCustomFunctions[fn]
      }
    )

    addCustomFunctionsForInterpreter(customFunctionsToBeAddedToTheInterpreter)
    set({ activatedCustomFunctions: newActivatedCustomFunctions })
  },
  deactivateCustomFunction: (name: string) => {
    const { activatedCustomFunctions, removeCustomFunctionForInterpreter } =
      get()

    const customFnsToBeRemovedFromInterpreter: string[] = []

    // we look for the element in the 2d array by the first position of the linkedFunctions array
    // that is the name of the function we want to remove
    const removedElement = activatedCustomFunctions.find((fn) => fn[0] === name)

    // if it doesn't exist, this function shouldn't have been called anyway
    if (!removedElement) return

    // we remove the element from the 2d array + possible duplicates with filter
    const newActivatedCustomFunctions = activatedCustomFunctions.filter(
      (fn) => fn[0] !== name
    )
    // we flatten the existing 2d array and create a set to get unique values
    const uniqueCustomFns = new Set(newActivatedCustomFunctions.flat())
    // we iterate over the linkedFunctions array we just removed
    for (const fn of removedElement) {
      // if the function is not in the set, it that function is not used anywhere else,
      // and is not a dependency of another function
      if (!uniqueCustomFns.has(fn)) {
        // we add it to the list of functions to be removed from the interpreter
        customFnsToBeRemovedFromInterpreter.push(fn)
      }
    }

    // then we remove the functions from the interpreter
    customFnsToBeRemovedFromInterpreter.forEach(
      removeCustomFunctionForInterpreter
    )

    set({ activatedCustomFunctions: newActivatedCustomFunctions })
  },

  getIsFunctionActivated: (name: string) => {
    const activatedCustomFunctions = get().activatedCustomFunctions
    const isActivated = activatedCustomFunctions
      .map((fn) => fn[0])
      .includes(name)
    return isActivated
  },

  populateCustomFunctionsForInterpreter: (customFunctionsForInterpreter) => {
    const newCustomFunctionsForInterpreter =
      customFunctionsForInterpreter.reduce((acc, fn) => {
        acc[fn.name] = fn
        return acc
      }, {})

    set({ customFunctionsForInterpreter: newCustomFunctionsForInterpreter })
  },
  customFunctionsForInterpreter: {},
  addCustomFunctionsForInterpreter: (customFunctionsForInterpreter) => {
    set((state) => {
      const newCustomFnsForInterpreter = customFunctionsForInterpreter.reduce(
        (acc, fn) => {
          acc[fn.name] = fn
          return acc
        },
        {}
      )

      const existingCustomFnsForInterpreter =
        state.customFunctionsForInterpreter
      const updatedCustomFnsForInterpreter = Object.assign(
        existingCustomFnsForInterpreter,
        newCustomFnsForInterpreter
      )

      return {
        customFunctionsForInterpreter: updatedCustomFnsForInterpreter,
      }
    })
  },
  removeCustomFunctionForInterpreter: (name) => {
    set((state) => {
      const customFunctionsForInterpreter = state.customFunctionsForInterpreter
      delete customFunctionsForInterpreter[name]

      return {
        customFunctionsForInterpreter,
      }
    })
  },
}))

export default useCustomFunctionStore
