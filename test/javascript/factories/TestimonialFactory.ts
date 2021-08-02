import { Testimonial } from '../../../app/javascript/components/types'
import { build, perBuild } from '@jackfranklin/test-data-bot'

export const createTestimonial = build<Testimonial>({
  fields: {
    uuid: 'uuid',
    content: 'Good mentor!',
    student: {
      avatarUrl: 'https://exercism.test/avatar.jpg',
      handle: 'student',
    },
    exercise: {
      iconUrl: 'https://exercism.test/lasagna.jpg',
      title: 'Lasagna',
    },
    track: {
      iconUrl: 'https://exercism.test/ruby.jpg',
      title: 'Ruby',
    },
    createdAt: new Date().toISOString(),
    isRevealed: perBuild(() => true),
    links: {
      reveal: 'https://exercism.test/testimonials/uuid/reveal',
      delete: 'https://exercism.test/testimonials/uuid',
    },
  },
})
