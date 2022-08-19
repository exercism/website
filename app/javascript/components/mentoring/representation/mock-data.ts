export const MOCK_REPRESENTATION_DATA = {
  student: {
    handle: 'alice',
    name: 'Alice',
    bio: null,
    location: null,
    languagesSpoken: ['english', 'spanish'],
    avatarUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg',
    reputation: '0',
    isFavorited: false,
    isBlocked: false,
    trackObjectives: 'get better',
    numTotalDiscussions: 1,
    numDiscussionsWithMentor: 1,
    links: {
      block: '/api/v2/mentoring/students/alice/block',
      favorite: '/api/v2/mentoring/students/alice/favorite',
      previousSessions:
        '/api/v2/mentoring/discussions?exclude_uuid=63b2c29073304a00b453c6d0e3dd0d31&status=all&student=alice',
    },
  },
  track: {
    slug: 'ruby',
    title: 'Ruby',
    highlightjsLanguage: 'ruby',
    indentSize: 2,
    medianWaitTime: null,
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/tracks/ruby.svg',
  },
  exercise: {
    slug: 'lasagna',
    title: 'Lasagna',
    iconUrl:
      'https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/exercises/lasagna.svg',
    links: {
      self: '/tracks/ruby/exercises/lasagna',
    },
  },
}
