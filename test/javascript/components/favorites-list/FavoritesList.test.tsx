import React from 'react'
import { render, screen, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import FavoritesList from '../../../../app/javascript/components/favorites-list'
import { useList } from '@/hooks/use-list'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { TrackData } from '@/components/profile/CommunitySolutionsList'
import {
  PaginatedResult,
  CommunitySolution as CommunitySolutionProps,
} from '@/components/types'

jest.mock('@/hooks/use-list')
jest.mock('@/hooks/request-query')
jest.mock('@/hooks/use-history', () => ({
  useHistory: () => {},
  removeEmpty: (q: unknown) => q,
}))
jest.mock('@/utils/use-storage', () => ({
  useLocalStorage: jest.fn().mockReturnValue(['grid-layout', jest.fn()]),
}))

const tracks: TrackData[] = [
  {
    slug: null,
    title: 'All Tracks',
    iconUrl: '',
    numSolutions: 15,
  },
  {
    slug: 'javascript',
    title: 'JavaScript',
    iconUrl: 'https://assets.exercism.org/tracks/javascript.svg',
    numSolutions: 4,
  },
  {
    slug: 'ruby',
    title: 'Ruby',
    iconUrl: 'https://assets.exercism.org/tracks/ruby.svg',
    numSolutions: 11,
  },
]

const initialRequest = {
  endpoint: 'http://local.exercism.io:3020/api/v2/favorites',
  query: {},
  options: {
    initialData: {
      results: [
        {
          uuid: '4aa129aa2e4c4300ba28d4e95cc24596',
          numIterations: 2,
          isOutOfDate: false,
          language: 'javascript',
          author: {
            handle: 'iHiD',
            avatarUrl: '/avatars/1530/0',
            flair: 'staff',
          },
          exercise: {
            title: "Lucian's Luscious Lasagna",
            iconUrl: 'https://assets.exercism.org/exercises/lasagna.svg',
          },
          track: {
            title: 'JavaScript',
            iconUrl: 'https://assets.exercism.org/tracks/javascript.svg',
          },
          links: {
            publicUrl:
              'http://local.exercism.io:3020/tracks/javascript/exercises/lasagna/solutions/iHiD',
          },
        },
      ],
      meta: {
        currentPage: 1,
        totalCount: 3,
        totalPages: 1,
        unscopedTotal: 3,
      },
    },
  },
}

const setupMocks = ({
  data = null,
  isFetching = false,
  status = 'success',
  error = null,
}: {
  data?: PaginatedResult<CommunitySolutionProps>[] | null
  isFetching?: boolean
  status?: string
  error?: Error | null
} = {}) => {
  ;(useList as jest.Mock).mockReturnValue({
    request: initialRequest,
    setCriteria: jest.fn(),
    setPage: jest.fn(),
    setQuery: jest.fn(),
  })
  ;(usePaginatedRequestQuery as jest.Mock).mockReturnValue({
    data,
    isFetching,
    status,
    error,
  })
}

test('renders solutions and pagination from initial data', () => {
  setupMocks({
    // @ts-ignore
    data: initialRequest.options.initialData,
  })

  render(<FavoritesList tracks={tracks} request={initialRequest} />)

  expect(screen.getByText(/Lucian's Luscious Lasagna/i)).toBeInTheDocument()
  expect(screen.getByText(/JavaScript/i)).toBeInTheDocument()
  expect(
    screen.getByRole('link', {
      name: /lucian's luscious lasagna/i,
    })
  ).toHaveAttribute(
    'href',
    'http://local.exercism.io:3020/tracks/javascript/exercises/lasagna/solutions/iHiD'
  )
})

test('shows NoFavoritesYet if unscopedTotal is 0 and no results', () => {
  const requestWith0Total = {
    ...initialRequest,
    options: {
      initialData: {
        results: [],
        meta: {
          ...initialRequest.options.initialData.meta,
          unscopedTotal: 0,
          totalCount: 0,
          totalPages: 0,
        },
      },
    },
  }

  setupMocks({
    // @ts-ignore
    data: requestWith0Total.options.initialData,
    isFetching: false,
  })

  render(<FavoritesList tracks={tracks} request={requestWith0Total} />)

  expect(screen.getByText('No favorites yet.')).toBeInTheDocument()
})

test('shows NoResults when no results returned from API', () => {
  setupMocks({
    data: {
      // @ts-ignore
      results: [],
      meta: { totalPages: 0 },
    },
    isFetching: false,
  })

  render(<FavoritesList tracks={tracks} request={initialRequest} />)

  expect(screen.getByText('No solutions found.')).toBeInTheDocument()
})

test('shows default error if query fails', () => {
  setupMocks({
    status: 'error',
    error: new Error('Failure'),
  })

  render(<FavoritesList tracks={tracks} request={initialRequest} />)

  expect(screen.getByText('Unable to pull solutions')).toBeInTheDocument()
})

test('can change search input value', () => {
  setupMocks()

  render(<FavoritesList tracks={tracks} request={initialRequest} />)

  const input = screen.getByPlaceholderText(/search by code/i)
  fireEvent.change(input, { target: { value: 'lasagna' } })
  expect(input).toHaveValue('lasagna')
})

test('does not crash if tracks array is empty', () => {
  setupMocks()
  render(<FavoritesList tracks={[]} request={initialRequest} />)
  expect(screen.queryByRole('combobox')).not.toBeInTheDocument()
})
