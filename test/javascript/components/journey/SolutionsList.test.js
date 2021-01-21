import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { SolutionsList } from '../../../../app/javascript/components/journey/SolutionsList'
import userEvent from '@testing-library/user-event'

test('pulls solutions', async () => {
  const solutions = [
    {
      id: 'uuid-1',
      exercise: {
        title: 'Lasagna',
      },
      track: {},
    },
    {
      id: 'uuid-2',
      exercise: {
        title: 'Bob',
      },
      track: {},
    },
  ]

  const server = setupServer(
    rest.get('https://exercism.test/solutions', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          results: solutions,
          meta: {
            current: 1,
            total: 1,
          },
        })
      )
    })
  )
  server.listen()

  render(<SolutionsList endpoint="https://exercism.test/solutions" />)

  expect(await screen.findByText('Showing 2 solutions')).toBeInTheDocument()
  expect(await screen.findByText('Lasagna')).toBeInTheDocument()
  expect(await screen.findByText('Bob')).toBeInTheDocument()

  server.close()
})

test('paginates solutions', async () => {
  const solutions = [
    {
      id: 'uuid-1',
      exercise: {
        title: 'Lasagna',
      },
      track: {},
    },
    {
      id: 'uuid-2',
      exercise: {
        title: 'Bob',
      },
      track: {},
    },
  ]

  const server = setupServer(
    rest.get('https://exercism.test/solutions', (req, res, ctx) => {
      const page = req.url.searchParams.get('page')

      const response = {
        results: [solutions[page - 1]],
        meta: {
          current: page,
          total: 2,
        },
      }
      return res(ctx.status(200), ctx.json(response))
    })
  )
  server.listen()

  render(<SolutionsList endpoint="https://exercism.test/solutions" />)

  userEvent.click(await screen.findByRole('button', { name: 'Go to page 2' }))

  expect(await screen.findByText('Bob')).toBeInTheDocument()

  server.close()
})

test('searches solutions', async () => {
  const solutions = [
    {
      id: 'uuid-1',
      exercise: {
        title: 'Lasagna',
      },
      track: {},
    },
    {
      id: 'uuid-2',
      exercise: {
        title: 'Bob',
      },
      track: {},
    },
  ]

  const server = setupServer(
    rest.get('https://exercism.test/solutions', (req, res, ctx) => {
      const criteria = req.url.searchParams.get('criteria')

      const searched = solutions.filter(
        (solution) => solution.exercise.title === criteria
      )

      const response = {
        results: searched,
        meta: {
          current: 1,
          total: searched.length,
        },
      }
      return res(ctx.status(200), ctx.json(response))
    })
  )
  server.listen()

  render(<SolutionsList endpoint="https://exercism.test/solutions" />)

  userEvent.type(screen.getByPlaceholderText('Search for an exercise'), 'Bob')

  expect(await screen.findByText('Bob')).toBeInTheDocument()

  server.close()
})

test('filters solutions', async () => {
  const solutions = [
    {
      id: 'uuid-1',
      exercise: {
        title: 'Lasagna',
      },
      track: {},
      status: 'published',
      mentoringStatus: 'in_progress',
    },
    {
      id: 'uuid-2',
      exercise: {
        title: 'Bob',
      },
      track: {},
      status: 'published',
      mentoringStatus: 'requested',
    },
  ]

  const server = setupServer(
    rest.get('https://exercism.test/solutions', (req, res, ctx) => {
      const status = req.url.searchParams.get('status')
      const mentoringStatus = req.url.searchParams.get('mentoring_status')

      const searched = solutions
        .filter((solution) => solution.status.includes(status))
        .filter((solution) =>
          solution.mentoringStatus.includes(mentoringStatus)
        )

      const response = {
        results: searched,
        meta: {
          current: 1,
          total: searched.length,
        },
      }
      return res(ctx.status(200), ctx.json(response))
    })
  )
  server.listen()

  render(<SolutionsList endpoint="https://exercism.test/solutions" />)

  userEvent.click(screen.getByRole('button', { name: 'Filter by' }))
  userEvent.click(screen.getByLabelText('Completed and published'))
  userEvent.click(screen.getByLabelText('Requested'))
  userEvent.click(screen.getByRole('button', { name: 'Apply' }))

  expect(await screen.findByText('Bob')).toBeInTheDocument()
  expect(screen.queryByText('Lasagna')).not.toBeInTheDocument()

  server.close()
})

test('sorts solutions', async () => {
  let solutions = [
    {
      id: 'uuid-1',
      exercise: {
        title: 'Lasagna',
      },
      track: {},
    },
    {
      id: 'uuid-2',
      exercise: {
        title: 'Bob',
      },
      track: {},
    },
  ]

  const server = setupServer(
    rest.get('https://exercism.test/solutions', (req, res, ctx) => {
      const sort = req.url.searchParams.get('sort')

      if (sort === 'newest_first') {
        solutions = solutions.reverse()
      }

      const response = {
        results: [solutions[0]],
        meta: {
          current: 1,
          total: 1,
        },
      }
      return res(ctx.status(200), ctx.json(response))
    })
  )
  server.listen()

  render(<SolutionsList endpoint="https://exercism.test/solutions" />)
  expect(await screen.findByText('Lasagna')).toBeInTheDocument()

  userEvent.selectOptions(screen.getByRole('combobox'), ['newest_first'])

  expect(await screen.findByText('Bob')).toBeInTheDocument()

  server.close()
})
