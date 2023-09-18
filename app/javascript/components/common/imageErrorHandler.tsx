import { assetUrl } from '../../utils/assets'

const missingExerciseIcon = assetUrl('graphics/missing-exercise.svg')
const missingTrackIcon = assetUrl('graphics/missing-track.svg')

const missingImageErrorHandler = (
  e: React.SyntheticEvent<HTMLImageElement, Event>,
  missingImage: string
) => {
  const el = e.target as HTMLImageElement
  if (el.src === missingImage) {
    return
  }
  el.onerror = null
  el.src = missingImage
}

export const missingExerciseIconErrorHandler = (
  e: React.SyntheticEvent<HTMLImageElement, Event>
): void => missingImageErrorHandler(e, missingExerciseIcon)

export const missingTrackIconErrorHandler = (
  e: React.SyntheticEvent<HTMLImageElement, Event>
): void => missingImageErrorHandler(e, missingTrackIcon)
