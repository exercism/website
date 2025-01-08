import DrawExercise from '../exercises/draw/DrawExercise'
import MazeExercise from '../exercises/maze/MazeExercise'
import WordleExercise from '../exercises/wordle/WordleExercise'

import { Exercise } from '../exercises/Exercise'

export type Project = new (...args: any[]) => Exercise
const projectsCache = new Map<any, any>()

projectsCache.set('draw', DrawExercise)
projectsCache.set('maze', MazeExercise)
projectsCache.set('wordle', WordleExercise)

export default projectsCache

export function getAndInitializeExerciseClass(config: Config): Exercise | null {
  if (!config.projectType) return null

  const Project = projectsCache.get(config.projectType)
  if (!Project) {
    return null
  }
  const exercise: Exercise = new Project()
  return exercise
}
