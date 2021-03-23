// import * as React from 'react'
// import { ExerciseStatusIndex } from '../concept-map-types'

// const ExerciseStatusIndexContext = React.createContext<ExerciseStatusIndex | null>(
//   null
// )

// export const ExerciseStatusIndexProvider = ({
//   statusIndex,
//   children,
// }: {
//   statusIndex: ExerciseStatusIndex
//   children: React.ReactNode
// }): JSX.Element => {
//   return (
//     <ExerciseStatusIndexContext.Provider value={statusIndex}>
//       {children}
//     </ExerciseStatusIndexContext.Provider>
//   )
// }

// export const useExerciseStatusIndex = (): ExerciseStatusIndex => {
//   const index = React.useContext(ExerciseStatusIndexContext)
//   if (!index) {
//     throw new Error(
//       'useExerciseStatusIndex must be used by a component within a ExerciseStatusIndexProvider'
//     )
//   }
//   return index
// }
