import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Task } from '../../../../../app/javascript/components/contributing/tasks-list/Task'
import { createTask } from '../../../factories/TaskFactory'

test('renders a task', async () => {
  const task = createTask({
    title: 'Fix bugs',
    isNew: true,
    track: {
      title: 'Ruby',
      iconUrl: 'https://exercism.test/tracks/ruby/icon.png',
    },
    tags: {
      action: 'create',
      type: 'docs',
      size: 'small',
      knowledge: 'elementary',
      module: 'analyzer',
    },
    links: {
      githubUrl: 'https://github.com/exercism/ruby/issues/123',
    },
  })

  render(<Task task={task} />)

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://github.com/exercism/ruby/issues/123'
  )
  expect(
    screen.getByRole('img', { name: 'Action: create' })
  ).toBeInTheDocument()
  expect(screen.getByText('Fix bugs')).toBeInTheDocument()
  expect(screen.getByText('New')).toBeInTheDocument()
  expect(screen.getByText('Ruby')).toBeInTheDocument()
  expect(
    screen.getByRole('img', { name: 'icon for Ruby track' })
  ).toHaveAttribute('src', 'https://exercism.test/tracks/ruby/icon.png')
  expect(screen.getByText('docs')).toBeInTheDocument()
  expect(screen.getByText('Knowledge: elementary')).toBeInTheDocument()
  expect(screen.getByText('s')).toBeInTheDocument()
  expect(screen.getByRole('img', { name: 'Analyzer' })).toBeInTheDocument()
})

test('hides new tag when task is not new', async () => {
  const task = createTask({ isNew: false })

  render(<Task task={task} />)

  expect(screen.queryByText('New')).not.toBeInTheDocument()
})
