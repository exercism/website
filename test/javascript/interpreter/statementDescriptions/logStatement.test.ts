import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

import { getTrueFunction, getFalseFunction } from './helpers'

test('literal', () => {
  const { frames } = interpret('log "Jeremy"')
  const actual = describeFrame(frames[0], [])
  assertHTML(actual, `<p>This logged <code>"Jeremy"</code>.</p>`, [
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
  })
})
