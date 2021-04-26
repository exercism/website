import { RepresenterFeedback } from '../../../app/javascript/components/mentoring/session/RepresenterFeedback'
import {
  Category,
  CategoryId,
  Track,
} from '../../../app/javascript/components/profile/ContributionsSummary'

export const createCategoryId = (categoryId?: CategoryId): CategoryId =>
  categoryId ? categoryId : 'publishing'

export const createCategory = (category?: Partial<Category>): Category => ({
  id: createCategoryId(),
  reputation: 140,
  metricFull: '1 solution published',
  metricShort: '1 solution',
  ...category,
})

export const createTrack = (track?: Partial<Track>): Track => ({
  id: 'javascript',
  title: 'JavaScript',
  iconUrl: '/icons/javascript.svg',
  categories: [
    {
      id: 'publishing',
      metricFull: 'No solutions published',
      metricShort: 'No solutions',
      reputation: 0,
    },
    {
      id: 'mentoring',
      metricFull: 'No students mentored',
      metricShort: 'No students',
      reputation: 0,
    },
    {
      id: 'authoring',
      metricFull: '3 exercises contributed',
      metricShort: '3 exercises',
      reputation: 50,
    },
    {
      id: 'building',
      metricFull: '2 PRs accepted',
      metricShort: '2 PRs accepted',
      reputation: 24,
    },
    {
      id: 'maintaining',
      metricFull: '6 PRs reviewed',
      metricShort: '6 PRs reviewed',
      reputation: 35,
    },
    {
      id: 'other',
      reputation: 0,
    },
  ],
  ...track,
})

export const totalTrackReputation = (track: Track): number => {
  return track.categories.reduce((sum: number, category: Category) => {
    return sum + category.reputation
  }, 0)
}
