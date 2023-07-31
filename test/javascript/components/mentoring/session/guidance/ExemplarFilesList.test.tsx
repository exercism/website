import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import {
  ExemplarFilesList,
  Props,
} from '../../../../../../app/javascript/components/mentoring/session/guidance/ExemplarFilesList'
import { build } from '@jackfranklin/test-data-bot'

const buildProps = build<Props>({
  fields: {
    files: [],
    language: 'ruby',
  },
})

test('renders filename when there are more than one files', async () => {
  const files = [
    {
      filename: 'exemplar1.rb',
      content: 'class Exemplar1\nend',
    },
    {
      filename: 'exemplar2.rb',
      content: 'class Exemplar2\nend',
    },
  ]

  render(<ExemplarFilesList {...buildProps()} files={files} />)

  expect(screen.getByText('exemplar1.rb')).toBeInTheDocument()
  expect(screen.getByText('exemplar2.rb')).toBeInTheDocument()
})

test('does not render filename when there is just one file', async () => {
  const files = [
    {
      filename: 'exemplar1.rb',
      content: 'class Exemplar1\nend',
    },
  ]

  render(<ExemplarFilesList {...buildProps()} files={files} />)

  expect(screen.queryByText('exemplar1.rb')).not.toBeInTheDocument()
})
