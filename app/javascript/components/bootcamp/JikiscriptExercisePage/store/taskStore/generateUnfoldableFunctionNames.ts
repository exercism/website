import useTaskStore from './taskStore'

export const generateUnfoldableFunctioNames = (): string[] => {
  const { tasks } = useTaskStore()
  if (tasks === null) return []

  return [
    ...new Set(
      tasks.map((task) => task.tests.map((test) => test.function)).flat()
    ),
  ]
}
