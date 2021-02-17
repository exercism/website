jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('displays introduction', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      introduction="Ruby is a nice and concise language"
      instructions={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  expect(
    await screen.findByText('Ruby is a nice and concise language')
  ).toBeInTheDocument()
})

test('displays introductions overview', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      instructions={{
        overview: 'There are a couple of tasks to work on',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  expect(
    await screen.findByText('There are a couple of tasks to work on')
  ).toBeInTheDocument()
})

test('displays debugging information', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      debugging="To debug, print to the console"
      instructions={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  expect(
    await screen.findByText('To debug, print to the console')
  ).toBeInTheDocument()
})
