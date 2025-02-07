import { interpret } from '@/interpreter/interpreter'
import { describeFrame, DescriptionContext } from '@/interpreter/frames'
import {
  getNameFunction,
  assertHTML,
  contextToDescriptionContext,
  getNameWithArgsFunction,
  mehFunction,
  mehWithArgsFunction,
} from './helpers'

test('no times', () => {
  const context = { externalFunctions: [getNameFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`
    repeat 0 times do
    end
  `)
  const actual = describeFrame(frames[0], descContext)
  assertHTML(
    actual,
    `<p>The repeat block was asked to run<code>0</code>times so this line did nothing.</p>`,
    [
      `<li>Jiki saw that the loop should be run<code>0</code>times and so decided not to do anything further on this line.</li>`,
    ]
  )
})

test('no times with a variable', () => {
  const context = { externalFunctions: [getNameFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`
    set count to 0
    repeat count times do
    end
  `)
  const actual = describeFrame(frames[1], descContext)
  assertHTML(
    actual,
    `<p>The repeat block was asked to run<code>0</code>times so this line did nothing.</p>`,
    [
      `<li>Jiki got the box called<code>count</code>off the shelves and took<code>0</code>out of it.</li>`,
      `<li>Jiki saw that the loop should be run<code>0</code>times and so decided not to do anything further on this line.</li>`,
    ]
  )
})

test('one time', () => {
  const context = { externalFunctions: [getNameFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`
    repeat 1 times do
    end
  `)
  const actual = describeFrame(frames[0], descContext)
  assertHTML(
    actual,
    `<p>This line started the 1st iteration of this repeat block.</p>`,
    [
      `<li>Jiki increased his internal counter for this loop to<code>1</code>, checked<code>1 &le; 1</code>, and decided to run the code block.</li>`,
    ]
  )
})
test('one time with a variable', () => {
  const context = { externalFunctions: [getNameFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`
    set count to 1
    repeat count times do
    end
  `)
  const actual = describeFrame(frames[1], descContext)
  assertHTML(
    actual,
    `<p>This line started the 1st iteration of this repeat block.</p>`,
    [
      `<li>Jiki got the box called<code>count</code>off the shelves and took<code>1</code>out of it.</li>`,
      `<li>Jiki increased his internal counter for this loop to<code>1</code>, checked<code>1 &le; 1</code>, and decided to run the code block.</li>`,
    ]
  )
})

test('multiple times', () => {
  const context = { externalFunctions: [getNameFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`
    repeat 2 times do
    end
  `)
  assertHTML(
    describeFrame(frames[0], descContext),
    `<p>This line started the 1st iteration of this repeat block.</p>`,
    [
      `<li>Jiki increased his internal counter for this loop to<code>1</code>, checked<code>1 &le; 2</code>, and decided to run the code block.</li>`,
    ]
  )
  assertHTML(
    describeFrame(frames[1], descContext),
    `<p>This line started the 2nd iteration of this repeat block.</p>`,
    [
      `<li>Jiki increased his internal counter for this loop to<code>2</code>, checked<code>2 &le; 2</code>, and decided to run the code block.</li>`,
    ]
  )
})
