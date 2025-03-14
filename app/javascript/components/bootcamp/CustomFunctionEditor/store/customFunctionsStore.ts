import { create } from 'zustand'
import { CustomFunction as CustomFunctionForInterpreter } from '@/interpreter/interpreter'

export type CustomFunctionMetadata = {
  name: string
  description: string
}
type CustomFunctionForInterpreterWithDependencies =
  CustomFunctionForInterpreter & {
    dependencies: string[]
  }

export type AvailableCustomFunctions = Record<
  string,
  CustomFunctionForInterpreterWithDependencies
>

type CustomFunctionsStore = {
  /**
   * Cache of available custom functions that can be passed into the interpreter
   */
  availableCustomFunctions: AvailableCustomFunctions
  addAvailableCustomFunction: (
    customFunction: CustomFunctionForInterpreterWithDependencies
  ) => void
  activateCustomFunction: (name: string, url: string) => void
  deactivateCustomFunction: (name: string) => void
  getIsFunctionActivated: (name: string) => boolean
  activatedCustomFunctions: string[][]
  setActivatedCustomFunctions: (activatedCustomFunctions: string[][]) => void
  customFunctionMetadataCollection: CustomFunctionMetadata[]
  setCustomFunctionMetadataCollection: (
    customFunctionMetadataCollection: CustomFunctionMetadata[]
  ) => void
  customFunctionsForInterpreter: Record<string, CustomFunctionForInterpreter>
  populateCustomFunctionsForInterpreter: (
    customFunctionsForInterpreter: CustomFunctionForInterpreter[]
  ) => void
  addCustomFunctionsForInterpreter: (
    customFunctionsForInterpreter: CustomFunctionForInterpreterWithDependencies[]
  ) => void
  removeCustomFunctionsForInterpreter: (name: string) => void
}

const useCustomFunctionStore = create<CustomFunctionsStore>((set, get) => ({
  availableCustomFunctions: {},
  addAvailableCustomFunction: (
    customFunction: CustomFunctionForInterpreterWithDependencies
  ) => {
    set((state) => {
      if (state.availableCustomFunctions.hasOwnProperty(customFunction.name)) {
        return state
      }
      const newAvailableCustomFunctions = {
        ...state.availableCustomFunctions,
        [customFunction.name]: customFunction,
      }
      return {
        availableCustomFunctions: newAvailableCustomFunctions,
      }
    })
  },
  activatedCustomFunctions: [],
  setActivatedCustomFunctions: (activatedCustomFunctions: string[][]) => {
    set({ activatedCustomFunctions })
  },
  addActivatedCustomFunction: (name: string[]) => {
    set((state) => {
      const activatedCustomFunctions = [...state.activatedCustomFunctions, name]
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

  activateCustomFunction: async (name: string, url: string) => {
    // get the function from the cache
    const customFunction = get().availableCustomFunctions[name]
    const {
      addAvailableCustomFunction,
      activatedCustomFunctions,
      addCustomFunctionsForInterpreter,
    } = get()

    // returns the 2d array of activated custom functions
    let newActivatedCustomFunctions = [...activatedCustomFunctions]
    let customFunctionsToBeAddedToTheInterpreter: CustomFunctionForInterpreterWithDependencies[] =
      []

    if (!customFunction) {
      const data = await getCustomFunctionsForInterpreter(url, name)
      const customFunctions = data.custom_functions
      // we build the deps - everything that is not `name` - the function we are adding
      const dependencies = customFunctions
        .filter((fn) => fn.name !== name)
        .map((fn) => fn.name)

      // we attach a `dependencies` array, so later we will know which additional functions to add
      // when we access it from the cache
      // and we build a list of actual functions we want to add to the interpreter in this round
      const customFunctionsWithDeps = customFunctions.map((fn) => {
        return { ...fn, dependencies: fn.name === name ? dependencies : [] }
      })

      // we add the newly fetched fns to the cache
      customFunctionsWithDeps.forEach(addAvailableCustomFunction)

      customFunctionsToBeAddedToTheInterpreter = customFunctionsWithDeps

      // we build a 2d array of activated custom functions,
      // where each function is represented as an array inside activatedCustomFunctions array.
      // this we call linkedFunctions
      // [function_we_want_to_activate, ...its_dependencies]
      const linkedFunctions = [name, ...dependencies]
      newActivatedCustomFunctions = [
        ...newActivatedCustomFunctions,
        linkedFunctions,
      ]
    } else {
      // if the function is already in the cache, we just
      const dependencies = customFunction.dependencies
      const linkedFunctions = [name, ...dependencies]
      newActivatedCustomFunctions = [
        ...newActivatedCustomFunctions,
        linkedFunctions,
      ]

      // we collect functions from the cache by going through the relation array
      customFunctionsToBeAddedToTheInterpreter = linkedFunctions.map((fn) => {
        return get().availableCustomFunctions[fn]
      })
    }

    addCustomFunctionsForInterpreter(customFunctionsToBeAddedToTheInterpreter)
    set({ activatedCustomFunctions: newActivatedCustomFunctions })
  },
  deactivateCustomFunction: (name: string) => {
    const { activatedCustomFunctions, removeCustomFunctionsForInterpreter } =
      get()
    const customFnsToBeRemovedFromInterpreter: string[] = []
    const newActivatedCustomFunctions = [...activatedCustomFunctions]

    // we look for the element in the 2d array by the first position of the linkedFunctions array
    // that is the name of the function we want to remove
    const indexToRemove = activatedCustomFunctions.findIndex(
      (fn) => fn[0] === name
    )

    // if it doesn't exist, this function shouldn't have been called anyway
    if (indexToRemove === -1) return

    // we mutate the newActivatedCustomFunctions array by removing the element
    // and retrieve the linkedFunctions array
    const [removedElement] = newActivatedCustomFunctions.splice(
      indexToRemove,
      1
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
      removeCustomFunctionsForInterpreter
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

  customFunctionMetadataCollection: [],
  setCustomFunctionMetadataCollection: (customFunctionMetadataCollection) => {
    set({ customFunctionMetadataCollection })
  },
  populateCustomFunctionsForInterpreter: (customFunctionsForInterpreter) => {
    console.log('customFunctionsForInterpreter', customFunctionsForInterpreter)

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
  removeCustomFunctionsForInterpreter: (name) => {
    console.log('removing custom fn', name)
    set((state) => {
      const customFunctionsForInterpreter = state.customFunctionsForInterpreter
      delete customFunctionsForInterpreter[name]

      console.log(
        'customFunctionsForInterpreter',
        customFunctionsForInterpreter
      )

      return {
        customFunctionsForInterpreter,
      }
    })
  },
}))

export default useCustomFunctionStore

export async function getCustomFunctionsForInterpreter(
  url: string,
  name: string
): Promise<{
  custom_functions: {
    code: string
    arity: number
    name: string
  }[]
}> {
  // bootcamp/custom_functions/for_interpreter?uuids=123,234,345
  const response = await fetch(url + '?name=' + encodeURIComponent(name), {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
    body: null,
  })

  if (!response.ok) {
    throw new Error('Failed to submit code')
  }

  return response.json()
}
