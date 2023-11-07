import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { default as IterationsList } from '@/components/student/IterationsList'
import userEvent from '@testing-library/user-event'
import { createIteration } from '../../factories/IterationFactory'
import { rest } from 'msw'
import { setupServer } from 'msw/node'

const server = setupServer(
  rest.get('https://exercism.test/iterations', (req, res, ctx) => {
    return res(ctx.status(200), ctx.json({ iterations: [] }))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('clicking cancel closes the delete modal', async () => {
  const iterations = [createIteration({})]
  const request = {
    endpoint: 'https://exercism.test/iterations',
    options: {
      initialData: {
        iterations: iterations,
      },
    },
  }
  render(
    <IterationsList
      solutionUuid="uuid"
      request={request}
      exercise={{
        title: 'Lasagna',
        downloadCmd: 'exercism download lasagna',
      }}
      track={{
        title: 'Ruby',
        iconUrl: 'https://exercism.test/ruby.png',
        highlightjsLanguage: 'ruby',
        indentSize: 2,
      }}
      links={{
        getMentoring: 'https://exercism.test/get_mentoring',
        automatedFeedbackInfo: 'https://exercism.test/automated_feedback_info',
        startExercise: 'https://exercism.test/start_exercise',
        solvingExercisesLocally:
          'https://exercism.test/solving_exercises_locally',
      }}
    />
  )

  userEvent.click(screen.getByAltText('Options for iteration 1'))
  userEvent.click(
    await screen.findByRole('button', { name: 'Delete iteration' })
  )
  userEvent.click(await screen.findByRole('button', { name: 'Cancel' }))

  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
