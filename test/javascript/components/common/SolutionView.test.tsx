import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import {
  SolutionView,
  Props,
} from '../../../../app/javascript/components/common/SolutionView'
import { createIteration } from '../../factories/IterationFactory'
import { build, perBuild } from '@jackfranklin/test-data-bot'

const buildProps = build<Props>({
  fields: {
    iterations: [createIteration({})],
    publishedIterationIdx: 1,
    publishedIterationIdxs: [1],
    language: 'ruby',
    indentSize: 2,
    outOfDate: perBuild(() => true),
    links: {},
  },
})

test('renders out of date notice', async () => {
  render(<SolutionView {...buildProps()} outOfDate />)

  expect(screen.getByText('Outdated')).toBeInTheDocument()
})

test('does not render out of date notice', async () => {
  render(<SolutionView {...buildProps()} outOfDate={false} />)

  expect(screen.queryByText('Outdated')).not.toBeInTheDocument()
})
