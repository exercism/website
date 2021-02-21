import React from 'react'
import { render, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { SearchableList } from '../../../../app/javascript/components/common/SearchableList'
import { rest } from 'msw'
import { setupServer } from 'msw/node'

const ResultsComponent = () => {
  return <div data-testid="results" />
}

test('hides pagination when totalPages < 1', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/endpoint', (req, res, ctx) => {
      return res(
        ctx.json({
          results: [],
          meta: {
            totalPages: 1,
          },
        })
      )
    })
  )
  server.listen()

  render(
    <SearchableList
      endpoint="https://exercism.test/endpoint"
      cacheKey="key"
      placeholder=""
      categories={[]}
      ResultsComponent={ResultsComponent}
    />
  )

  expect(await screen.findByTestId('results')).toBeInTheDocument()
  await waitFor(() =>
    expect(
      screen.queryByRole('button', { name: 'Go to first page' })
    ).not.toBeInTheDocument()
  )

  server.close()
})
