import { interpret } from '@/interpreter/interpreter'
import { describeFrame, DescriptionContext } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

const mehFunction = {
  name: 'meh',
  func: (_: any) => {},
  description: 'is a little meh',
}

const mehWithArgsFunction = {
  name: 'meh',
  func: (_: any, _2: any) => {},
  description: 'is a little meh',
}

const getNameWithArgsFunction = {
  name: 'get_name',
  func: (_: any, _2: any) => {
    return 'Jeremy'
  },
  description: 'always returns the string Jeremy',
}

const contextToDescriptionContext = (context): DescriptionContext => {
  // Convert array into object with name as key
  // and description as value
  const funcs = context.externalFunctions.reduce((acc, fn) => {
    acc[fn.name] = fn.description
    return acc
  }, {})

  return {
    functionDescriptions: funcs,
  }
}

test('naked, description, return', () => {
  const context = { externalFunctions: [getNameFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`get_name()`, context)
  const actual = describeFrame(frames[0], descContext)
  assertHTML(actual, `<p>This used the<code>get_name</code> function.</p>`, [
    `<li>Jiki used the<code>get_name()</code>function, which always returns the string Jeremy and returned<code>\"Jeremy\"</code>.</li>`,
  ])
})

test('naked, description, no return', () => {
  const context = { externalFunctions: [mehFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`meh()`, context)
  const actual = describeFrame(frames[0], descContext)
  assertHTML(actual, `<p>This used the<code>meh</code> function.</p>`, [
    `<li>Jiki used the<code>meh()</code>function, which is a little meh.</li>`,
  ])
})

test('naked, no description, return', () => {
  const { frames } = interpret(
    `
    function get_name do
      return "Jeremy"
    end
    get_name()`,
    {}
  )
  const actual = describeFrame(frames[1])
  assertHTML(actual, `<p>This used the<code>get_name</code> function.</p>`, [
    `<li>Jiki used the<code>get_name()</code>function, which returned<code>\"Jeremy\"</code>.</li>`,
  ])
})

test('naked, no description, no return', () => {
  const { frames } = interpret(
    `
    function get_name do
    end
    get_name()`,
    {}
  )
  const actual = describeFrame(frames[0])
  assertHTML(actual, `<p>This used the<code>get_name</code> function.</p>`, [
    `<li>Jiki used the<code>get_name()</code>function.</li>`,
  ])
})

test('args, description, return', () => {
  const context = { externalFunctions: [getNameWithArgsFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`get_name(1)`, context)
  const actual = describeFrame(frames[0], descContext)
  assertHTML(
    actual,
    `<p>This used the<code>get_name</code> function with the inputs <code>1</code>.</p>`,
    [
      `<li>Jiki used the<code>get_name(1)</code>function, which always returns the string Jeremy and returned<code>\"Jeremy\"</code>.</li>`,
    ]
  )
})

test('args, description, no return', () => {
  const context = { externalFunctions: [mehWithArgsFunction] }
  const descContext = contextToDescriptionContext(context)

  const { frames } = interpret(`meh(1)`, context)
  const actual = describeFrame(frames[0], descContext)
  assertHTML(
    actual,
    `<p>This used the<code>meh</code> function with the inputs <code>1</code>.</p>`,
    [
      `<li>Jiki used the<code>meh(1)</code>function, which is a little meh.</li>`,
    ]
  )
})

test('args, no description, return', () => {
  const { frames } = interpret(
    `
    function get_name with args do
      return "Jeremy"
    end
    get_name(1)`,
    {}
  )
  const actual = describeFrame(frames[1])
  assertHTML(
    actual,
    `<p>This used the<code>get_name</code> function with the inputs <code>1</code>.</p>`,
    [
      `<li>Jiki used the<code>get_name(1)</code>function, which returned<code>\"Jeremy\"</code>.</li>`,
    ]
  )
})

test('args, no description, no return', () => {
  const { frames } = interpret(
    `
    function get_name with x do
    end
    get_name(1)`,
    {}
  )
  const actual = describeFrame(frames[0])
  assertHTML(
    actual,
    `<p>This used the<code>get_name</code> function with the inputs <code>1</code>.</p>`,
    [`<li>Jiki used the<code>get_name(1)</code>function.</li>`]
  )
})
