import DrawExercise from '../exercises/draw/DrawExercise'
import MazeExercise from '../exercises/maze/MazeExercise'
import SpaceInvadersExercise from '../exercises/space_invaders/SpaceInvadersExercise'
import WordleExercise from '../exercises/wordle/WordleExercise'
import GolfExercise from '../exercises/golf/GolfExercise'
import DigitalClockExercise from '../exercises/time/DigitalClockExercise'
import RockPaperScissorsExercise from '../exercises/rock_paper_scissors/RockPaperScissorsExercise'
import TicTacToeExercise from '../exercises/tic_tac_toe/TicTacToeExercise'
import BreakoutExercise from '../exercises/breakout/BreakoutExercise'
import WeatherExercise from '../exercises/weather/WeatherExercise'
import HouseExercise from '../exercises/house/HouseExercise'
import DataExercise from '../exercises/data/DataExercise'
import FormalRobotsExercise from '../exercises/formal_robots/FormalRobotsExercise'

import { Exercise } from '../exercises/Exercise'

export interface ExerciseConstructor {
  new (...args: any[]): Exercise
  hasView: boolean
}
export type Project = ExerciseConstructor
const projectsCache = new Map<string, Project>()

projectsCache.set('draw', DrawExercise)
projectsCache.set('maze', MazeExercise)
projectsCache.set('wordle', WordleExercise)
projectsCache.set('golf', GolfExercise)
projectsCache.set('space-invaders', SpaceInvadersExercise)
projectsCache.set('digital-clock', DigitalClockExercise)
projectsCache.set('rock-paper-scissors', RockPaperScissorsExercise)
projectsCache.set('tic-tac-toe', TicTacToeExercise)
projectsCache.set('breakout', BreakoutExercise)
projectsCache.set('weather', WeatherExercise)
projectsCache.set('house', HouseExercise)
projectsCache.set('data', DataExercise)
projectsCache.set('formal-robots', FormalRobotsExercise)

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
