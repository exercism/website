import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import {
  getNameFunction,
  assertHTML,
  contextToDescriptionContext,
} from './helpers'
import * as Jiki from '@/interpreter/jikiObjects'

import { getTrueFunction, getFalseFunction } from './helpers'

const argyFunction = {
  name: 'argy_fn',
  func: (_, _1, _2) => new Jiki.String('Jeremy'),
  description: 'start ${arg1} and ${arg2} end',
}

test('literal', () => {
  const { frames } = interpret('log "Jeremy"')
  const actual = describeFrame(frames[0], [])
  assertHTML(actual, `<p>This logged <code>"Jeremy"</code>.</p>`, [
    `<li>Jiki wrote <code>"Jeremy"</code> here for you!</li>`,
  ])
})
test('variable', () => {
  const { frames } = interpret(`
    set name to "Jeremy"
    log name
    `)
  const actual = describeFrame(frames[1])
  assertHTML(actual, `<p>This logged <code>"Jeremy"</code>.</p>`, [
    `<li>Jiki got the box called <code data-hl-from=\"35\" data-hl-to=\"39\">name</code> off the shelves and took <code data-hl-from=\"35\" data-hl-to=\"39\">"Jeremy"</code> out of it.</li>`,
    `<li>Jiki wrote <code>"Jeremy"</code> here for you!</li>`,
  ])
})

test('function', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('log get_name()', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(actual, `<p>This logged <code>"Jeremy"</code>.</p>`, [
    `<li>Jiki used the <code>get_name()</code> function, which returned <code>"Jeremy"</code>.</li>`,
    `<li>Jiki wrote <code>"Jeremy"</code> here for you!</li>`,
  ])
})

test('function interpolation', () => {
  const context = { externalFunctions: [argyFunction] }
  const descContext = contextToDescriptionContext(context)
  const { frames } = interpret('log argy_fn(42, "foo")', context)
  const actual = describeFrame(frames[0], descContext)
  assertHTML(actual, `<p>This logged <code>"Jeremy"</code>.</p>`, [
    `<li>Jiki used the <code>argy_fn(42, "foo")</code> function, which start <code>42</code> and <code>"foo"</code> end. It returned <code>"Jeremy"</code>.</li>`,
    `<li>Jiki wrote <code>"Jeremy"</code> here for you!</li>`,
  ])
})

test('grouped function', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('log (get_name())', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(actual, `<p>This logged <code>"Jeremy"</code>.</p>`, [
    `<li>Jiki used the <code>get_name()</code> function, which returned <code>"Jeremy"</code>.</li>`,
    `<li>Jiki wrote <code>"Jeremy"</code> here for you!</li>`,
  ])
})

test('function with param', () => {
  const { frames } = interpret(`
      function ret_true with value do
        return true
      end
      log ret_true(1)
    `)
  const actual = describeFrame(frames[1], [])
  assertHTML(actual, `<p>This logged<code>true</code>.</p>`, [
    `<li>Jiki used the<code>ret_true(1)</code>function, which returned<code>true</code>.</li>`,
    `<li>Jiki wrote<code>true</code>here for you!</li>`,
  ])
})

test('nested functions', () => {
  const { frames } = interpret(`
      function ret_true with input do
        return input
      end
      log ret_true(ret_true(true))
    `)
  const actual = describeFrame(frames[2])
  assertHTML(actual, `<p>This logged<code>true</code>.</p>`, [
    `<li>Jiki used the<code>ret_true(true)</code>function, which returned<code>true</code>.</li>`,
    `<li>Jiki used the<code>ret_true(true)</code>function, which returned<code>true</code>.</li>`,
    `<li>Jiki wrote<code>true</code>here for you!</li>`,
  ])
})

describe('binary comaprisons', () => {
  test('greater than', () => {
    const { frames } = interpret('log 5 > 3', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
      `<li>Jiki evaluated <code>5 > 3</code> and determined it was <code>true</code>.</li>`,
      `<li>Jiki wrote <code>true</code> here for you!</li>`,
    ])
  })

  test('less than', () => {
    const { frames } = interpret('log 5 < 3', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
      `<li>Jiki evaluated <code>5 < 3</code> and determined it was <code>false</code>.</li>`,
      `<li>Jiki wrote <code>false</code> here for you!</li>`,
    ])
  })

  test('greater than or equal', () => {
    const { frames } = interpret('log 5 >= 3', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
      `<li>Jiki evaluated <code>5 >= 3</code> and determined it was <code>true</code>.</li>`,
      `<li>Jiki wrote <code>true</code> here for you!</li>`,
    ])
  })

  test('less than or equal', () => {
    const { frames } = interpret('log 5 <= 3', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
      `<li>Jiki evaluated <code>5 <= 3</code> and determined it was <code>false</code>.</li>`,
      `<li>Jiki wrote <code>false</code> here for you!</li>`,
    ])
  })

  test('equal', () => {
    const { frames } = interpret('log 5 == 3', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
      `<li>Jiki evaluated <code>5 == 3</code> and determined it was <code>false</code>.</li>`,
      `<li>Jiki wrote <code>false</code> here for you!</li>`,
    ])
  })

  test('not equal', () => {
    const { frames } = interpret('log 5 != 3', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
      `<li>Jiki evaluated <code>5 != 3</code> and determined it was <code>true</code>.</li>`,
      `<li>Jiki wrote <code>true</code> here for you!</li>`,
    ])
  })
  test('equal with bools', () => {
    const { frames } = interpret('log true == false', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
      `<li>Jiki evaluated <code>true == false</code> and determined it was <code>false</code>.</li>`,
      `<li>Jiki wrote <code>false</code> here for you!</li>`,
    ])
  })
  test('equal with funcs', () => {
    const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
    const { frames } = interpret('log get_true() == get_false()', context)
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
      `<li>Jiki used the<code>get_true()</code>function, which returned<code>true</code>.</li>`,
      `<li>Jiki used the<code>get_false()</code>function, which returned<code>false</code>.</li>`,
      `<li>Jiki evaluated <code>true == false</code> and determined it was <code>false</code>.</li>`,
      `<li>Jiki wrote <code>false</code> here for you!</li>`,
    ])
  })
  test('func vs bool', () => {
    const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
    const { frames } = interpret('log get_true() == true', context)
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
      `<li>Jiki used the<code>get_true()</code>function, which returned<code>true</code>.</li>`,
      `<li>Jiki evaluated <code>true == true</code> and determined it was <code>true</code>.</li>`,
      `<li>Jiki wrote <code>true</code> here for you!</li>`,
    ])
  })
  test('bool vs func', () => {
    const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
    const { frames } = interpret('log true == get_false()', context)
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
      `<li>Jiki used the<code>get_false()</code>function, which returned<code>false</code>.</li>`,
      `<li>Jiki evaluated <code>true == false</code> and determined it was <code>false</code>.</li>`,
      `<li>Jiki wrote <code>false</code> here for you!</li>`,
    ])
  })
  test('grouped', () => {
    const { frames } = interpret('log (5 > 3)', {})
    const actual = describeFrame(frames[0], [])
    assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
      `<li>Jiki evaluated <code>5 > 3</code> and determined it was <code>true</code>.</li>`,
      `<li>Jiki wrote <code>true</code> here for you!</li>`,
    ])
  })
})

describe('logical expression', () => {
  describe('short circuit', () => {
    test('false and true', () => {
      const { frames } = interpret('log true or false', {})
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
        `<li>Jiki saw the left side of the <code>or</code> was <code>true</code> and so did not bother looking at the right side.</li>`,
        `<li>Jiki wrote <code>true</code> here for you!</li>`,
      ])
    })
    test('false and true', () => {
      const { frames } = interpret('log false and false', {})
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
        `<li>Jiki saw the left side of the <code>and</code> was <code>false</code> and so did not bother looking at the right side.</li>`,
        `<li>Jiki wrote <code>false</code> here for you!</li>`,
      ])
    })

    test('false and true functions', () => {
      const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
      const { frames } = interpret('log get_true() or get_false()', context)
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
        `<li>Jiki used the<code>get_true()</code>function, which returned<code>true</code>.</li>`,
        `<li>Jiki saw the left side of the <code>or</code> was <code>true</code> and so did not bother looking at the right side.</li>`,
        `<li>Jiki wrote <code>true</code> here for you!</li>`,
      ])
    })
    test('false and true functions', () => {
      const context = { externalFunctions: [getFalseFunction] }
      const { frames } = interpret('log get_false() and get_true()', context)
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
        `<li>Jiki used the<code>get_false()</code>function, which returned<code>false</code>.</li>`,
        `<li>Jiki saw the left side of the <code>and</code> was <code>false</code> and so did not bother looking at the right side.</li>`,
        `<li>Jiki wrote <code>false</code> here for you!</li>`,
      ])
    })
  })
  describe('full evalution', () => {
    test('true and true', () => {
      const context = { externalFunctions: [getNameFunction] }
      const { frames } = interpret('log true and false', context)
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
        `<li>Jiki saw the left side of the<code>and</code>was<code>true</code>and so decided to evaluate the right side.</li>`,
        `<li>Jiki evaluated <code>true and false</code> and determined the result was<code>false</code>.</li>`,
        `<li>Jiki wrote <code>false</code> here for you!</li>`,
      ])
    })

    test('function and function - true', () => {
      const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
      const { frames } = interpret('log get_true() and get_false()', context)
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
        `<li>Jiki used the <code>get_true()</code> function, which returned <code>true</code>.</li>`,
        `<li>Jiki used the <code>get_false()</code> function, which returned <code>false</code>.</li>`,
        `<li>Jiki evaluated <code>true and false</code> and determined the result was<code>false</code>.</li>`,
        `<li>Jiki wrote <code>false</code> here for you!</li>`,
      ])
    })

    test('complex statement with comparisons', () => {
      const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
      const { frames } = interpret(
        'log get_true() is true and get_false() != true',
        context
      )
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
        `<li>Jiki used the <code>get_true()</code> function, which returned <code>true</code>.</li>`,
        `<li>Jiki evaluated<code>true is true</code>and determined it was<code>true</code>.</li>`,
        `<li>Jiki used the <code>get_false()</code> function, which returned <code>false</code>.</li>`,
        `<li>Jiki evaluated<code>false != true</code>and determined it was<code>true</code>.</li>`,
        `<li>Jiki evaluated <code>true and true</code> and determined the result was<code>true</code>.</li>`,
        `<li>Jiki wrote <code>true</code> here for you!</li>`,
      ])
    })
  })
  describe('chained', () => {
    test('complex statement with and comparisons', () => {
      const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
      const { frames } = interpret(
        'log get_true() and true and get_false() != true',
        context
      )
      const actual = describeFrame(frames[0], [])
      assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
        `<li>Jiki used the <code>get_true()</code> function, which returned <code>true</code>.</li>`,
        `<li>Jiki evaluated<code>true and true</code>and determined the result was<code>true</code>.</li>`,
        `<li>Jiki used the <code>get_false()</code> function, which returned <code>false</code>.</li>`,
        `<li>Jiki evaluated<code>false != true</code>and determined it was<code>true</code>.</li>`,
        `<li>Jiki evaluated <code>true and true</code> and determined the result was<code>true</code>.</li>`,
        `<li>Jiki wrote <code>true</code> here for you!</li>`,
      ])
    })
  })
  describe('chained', () => {
    test('complex statement with and/or comparisons', () => {
      const context = { externalFunctions: [getTrueFunction, getFalseFunction] }
      const { frames } = interpret(
        'log get_true() and (false or get_false() != true)',
        context
      )
      const actual = describeFrame(frames[0])
      assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
        `<li>Jiki used the <code>get_true()</code> function, which returned <code>true</code>.</li>`,
        `<li>Jiki saw the left side of the<code>or</code>was<code>false</code>and so decided to evaluate the right side.</li>`,
        `<li>Jiki used the <code>get_false()</code> function, which returned <code>false</code>.</li>`,
        `<li>Jiki evaluated<code>false != true</code>and determined it was<code>true</code>.</li>`,
        `<li>Jiki evaluated<code>false or true</code>and determined the result was<code>true</code>.</li>`,
        `<li>Jiki evaluated <code>true and true</code> and determined the result was<code>true</code>.</li>`,
        `<li>Jiki wrote <code>true</code> here for you!</li>`,
      ])
    })
  })
})

describe('unary', () => {
  describe('not', () => {
    test('simple boolean', () => {
      const { frames } = interpret('log not true')
      const actual = describeFrame(frames[0])
      assertHTML(actual, `<p>This logged <code>false</code>.</p>`, [
        `<li>Jiki evaluated that<code>not true</code>is<code>false</code>.</li>`,
        `<li>Jiki wrote<code>false</code>here for you!</li>`,
      ])
    })
    test('expression', () => {
      const { frames } = interpret('log not (true == false)')
      const actual = describeFrame(frames[0])
      assertHTML(actual, `<p>This logged <code>true</code>.</p>`, [
        `<li>Jiki evaluated<code>true == false</code>and determined it was<code>false</code>.</li>`,
        `<li>Jiki evaluated that<code>not false</code>is<code>true</code>.</li>`,
        `<li>Jiki wrote<code>true</code>here for you!</li>`,
      ])
    })
  })
  describe('minus', () => {
    test('number is no-op', () => {
      const { frames } = interpret('log -1')
      const actual = describeFrame(frames[0])
      assertHTML(actual, `<p>This logged <code>-1</code>.</p>`, [
        `<li>Jiki wrote<code>-1</code>here for you!</li>`,
      ])
    })
    test('expression', () => {
      const { frames } = interpret('log -(3 - 2)')
      const actual = describeFrame(frames[0])
      assertHTML(actual, `<p>This logged <code>-1</code>.</p>`, [
        `<li>Jiki evaluated<code>3 - 2</code>and determined it was<code>1</code>.</li>`,
        `<li>Jiki evaluated that<code>-1</code>is<code>-1</code>.</li>`,
        `<li>Jiki wrote<code>-1</code>here for you!</li>`,
      ])
    })
  })
})
