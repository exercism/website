import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import {
  Guidance,
  Props,
} from '../../../../../app/javascript/components/mentoring/session/Guidance'
import { build } from '@jackfranklin/test-data-bot'
import { SessionGuidance } from '../../../../../app/javascript/components/mentoring/Session'

const buildProps = build<Props>({
  fields: {
    guidance: {
      exercise: 'Helpful notes for a good lasagna',
      track: 'Guidance for good Ruby mentoring',
    },
    exemplarFiles: [],
    language: 'ruby',
    links: {},
  },
})

test('how you solved the exercise is open by default', async () => {
  render(<Guidance {...buildProps()} feedback={{}} />)

  expect(
    screen.getByRole('button', { name: 'Exercise notes' })
  ).toHaveAttribute('aria-expanded', 'true')
  expect(
    screen.getByRole('button', { name: 'Automated feedback' })
  ).toHaveAttribute('aria-expanded', 'false')
})

test('open and close same accordion', async () => {
  render(<Guidance {...buildProps()} />)

  userEvent.click(screen.getByRole('button', { name: 'Exercise notes' }))

  expect(
    await screen.findByRole('button', { name: 'Exercise notes' })
  ).toHaveAttribute('aria-expanded', 'false')
})

test('only one accordion is open at a time', async () => {
  render(<Guidance {...buildProps()} feedback={{}} />)

  userEvent.click(screen.getByRole('button', { name: 'Automated feedback' }))

  expect(
    screen.getByRole('button', { name: 'Exercise notes' })
  ).toHaveAttribute('aria-expanded', 'false')
  expect(
    screen.getByRole('button', { name: 'Automated feedback' })
  ).toHaveAttribute('aria-expanded', 'true')
})

test('displays notes', async () => {
  const guidance: SessionGuidance = {
    exercise: '<h2>Notes</h2>',
    track: '',
    links: { improveExerciseGuidance: '', improveTrackGuidance: '' },
  }
  render(<Guidance {...buildProps()} guidance={guidance} />)

  expect(screen.getByRole('heading', { name: 'Notes' })).toBeInTheDocument()
})

test('hides how you solved the solution if mentor solution is null', async () => {
  const guidance: SessionGuidance = {
    exercise: '<h2>Notes</h2>',
    track: '',
    links: { improveExerciseGuidance: '', improveTrackGuidance: '' },
  }
  render(<Guidance {...buildProps()} guidance={guidance} />)

  expect(
    screen.queryByRole('button', { name: 'How you solved the exercise' })
  ).not.toBeInTheDocument()
})
