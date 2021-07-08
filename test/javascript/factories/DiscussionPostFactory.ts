import { DiscussionPostProps } from '../../../app/javascript/components/mentoring/discussion/DiscussionPost'

export const createDiscussionPost = (
  props: Partial<DiscussionPostProps>
): DiscussionPostProps => {
  return {
    uuid: 'uuid',
    iterationIdx: 1,
    authorHandle: 'author',
    authorAvatarUrl: 'http://exercism.test/image',
    byStudent: false,
    contentMarkdown: '# Hello',
    contentHtml: '<p>Hello</p>',
    updatedAt: new Date().toISOString(),
    links: {
      update: 'https://exercism.test/links/1',
    },
    ...props,
  }
}
