import { assetUrl } from '../../utils/assets'

const missingExerciseIcon = assetUrl('graphics/missing-exercise.svg')

const missingImageErrorHandler = (
  e: React.SyntheticEvent<HTMLImageElement, Event>,
  missingImage: string
) => {
  const el = e.target as HTMLImageElement
  if ((el.src = missingExerciseIcon)) {
    return
  }
  el.onerror = null
  el.src = missingImage
}

export const missingExerciseIconErrorHandler = (
  e: React.SyntheticEvent<HTMLImageElement, Event>
) => missingImageErrorHandler(e, missingExerciseIcon)
