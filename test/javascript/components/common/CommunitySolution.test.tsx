import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { CommunitySolution } from '../../../../app/javascript/components/common/CommunitySolution'
import { IterationStatus } from '../../../../app/javascript/components/types'

test('shows CTA to contribute notes when notes isnt present', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="mentoring"
    />
  )

  expect(
    screen.queryByAltText('Number of times solution has been starred')
  ).not.toBeInTheDocument()
})

test('links to private url if context is mentoring', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="mentoring"
    />
  )

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/private'
  )
})

test('links to public url if context is profile', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="profile"
    />
  )

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/public'
  )
})

test('links to public url if context is exercise', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="exercise"
    />
  )

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/public'
  )
})

test('shows author avatar if context is exercise', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="exercise"
    />
  )

  expect(
    screen.getByRole('img', { name: 'Uploaded avatar of handle' })
  ).toHaveAttribute('src', 'url')
})
test('shows author avatar if context is profile', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="profile"
    />
  )

  expect(
    screen.getByRole('img', { name: 'Uploaded avatar of handle' })
  ).toHaveAttribute('src', 'url')
  expect(
    screen.queryByRole('img', { name: 'Icon for exercise called Exercise' })
  ).not.toBeInTheDocument()
})

test('shows exercise icon if context is mentoring', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="mentoring"
    />
  )

  expect(
    screen.getByRole('img', { name: 'Icon for exercise called Exercise' })
  ).toHaveAttribute('src', 'https://exercism.test/icon')
  expect(
    screen.queryByRole('img', { name: 'Uploaded avatar of handle' })
  ).not.toBeInTheDocument()
})

test('shows "Your solution" if context is mentoring', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="mentoring"
    />
  )

  expect(screen.getByText('Your Solution')).toBeInTheDocument()
})

test('shows "Your solution" if context is profile', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="profile"
    />
  )

  expect(screen.getByText("handle's solution")).toBeInTheDocument()
})

test('shows "Your solution" if context is exercise', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="exercise"
    />
  )

  expect(screen.getByText("handle's solution")).toBeInTheDocument()
})

test('renders processing status', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="exercise"
    />
  )

  expect(screen.getByText('Processing')).toBeInTheDocument()
})

test('renders warning icon when solution is out of date', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: true,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="exercise"
    />
  )

  expect(
    screen.getByRole('img', {
      name:
        'This solution has not been tested against the latest version of this exercise',
    })
  ).toBeInTheDocument()
})

test('does not render warning icon when solution is not out of date', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    iterationStatus: IterationStatus.ANALYZING,
    isOutOfDate: false,
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution
      solution={solution}
      exercise={exercise}
      track={track}
      context="exercise"
    />
  )

  expect(
    screen.queryByRole('img', {
      name:
        'This solution has not been tested against the latest version of this exercise',
    })
  ).not.toBeInTheDocument()
})
