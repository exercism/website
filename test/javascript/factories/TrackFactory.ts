import { Track } from '../../../app/javascript/components/types'

export const createTrack = (track?: Partial<Track>): Track => ({
  id: 'ruby',
  slug: 'ruby',
  title: 'Ruby',
  iconUrl: 'https://exercism.test/tracks/ruby.svg',
  numConcepts: 10,
  numExercises: 5,
  numSolutions: 10,
  links: {
    self: 'https://exercism.test/tracks/ruby',
    exercises: 'https://exercism.test/tracks/ruby/exercises',
    concepts: 'https://exercism.test/tracks/ruby/concepts',
  },
  ...track,
})
