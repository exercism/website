import { MentorDiscussion } from '../../../app/javascript/components/types'

export const createMentorDiscussion = (
  props: Partial<MentorDiscussion> = {}
): MentorDiscussion => {
  return {
    uuid: 'mentor-discussion',
    status: 'awaiting_mentor',
    finishedAt: new Date().toISOString(),
    finishedBy: 'mentor',
    student: {
      avatarUrl: 'https://exercism.test/users/student.jpg',
      handle: 'student',
      isFavorited: false,
    },
    mentor: {
      avatarUrl: 'https://exercism.test/users/mentor.jpg',
      handle: 'mentor',
    },
    track: {
      title: 'Ruby',
      iconUrl: 'https://exercism.test/tracks/ruby.jpg',
    },
    exercise: {
      title: 'Strings',
      iconUrl: 'https://exercism.test/exercises/strings.jpg',
    },
    isFinished: false,
    isUnread: false,
    isFavorited: false,
    postsCount: 15,
    iterationsCount: 2,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    links: {
      self: 'https://exercism.test/discussions/1',
      posts: 'https://exercism.test/discussions/1/posts',
      markAsNothingToDo:
        'https://exercism.test/discussions/1/mark_as_nothing_to_do',
      finish: 'https://exercism.test/discussions/1/finish',
    },
    ...props,
  }
}
