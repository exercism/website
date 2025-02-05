import { interpret } from '@/interpreter/interpreter'
import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'
import { describeFrame } from '@/interpreter/frames'
import { marked } from 'marked'

const location = new Location(0, new Span(0, 0), new Span(0, 0))
const getNameFunction = {
  name: 'get_name',
  func: (_interpreter: any) => {
    return 'Jeremy'
  },
  description: '',
}
const getTrueFunction = {
  name: 'get_true',
  func: (_interpreter: any) => {
    return true
  },
  description: '',
}
const getFalseFunction = {
  name: 'get_false',
  func: (_interpreter: any) => {
    return false
  },
  description: '',
}

describe('SetVariableStatement', () => {
  describe('description', () => {
    test('standard', () => {
      const { frames } = interpret('set my_name to "Jeremy"')
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        '<p>This created a new variable called <code>my_name</code> and sets its value to <code>"Jeremy"</code>.</p>'
      )
    })
    test('function', () => {
      const { frames } = interpret('set my_name to get_name()', {
        externalFunctions: [getNameFunction],
      })
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        '<p>This created a new variable called <code>my_name</code> and sets its value to <code>"Jeremy"</code>.</p>'
      )
    })
  })
})

describe('ChangeVariableStatement', () => {
  describe('description', () => {
    test('standard', () => {
      const { frames } = interpret(`
        set my_name to "Aron"
        change my_name to "Jeremy"
        `)
      const actual = describeFrame(frames[1], [])
      expect(actual).toBe(
        '<p>This updated the variable called <code>my_name</code> from...</p><pre><code>"Aron"</code></pre><p>to...</p><pre><code>"Jeremy"</code></pre>'
      )
    })
  })
})

describe('ReturnStatement', () => {
  test('no value', () => {
    const { frames } = interpret(`
      function get_name do
        return
      end
      get_name()
    `)
    const actual = describeFrame(frames[0], [])
    expect(actual).toBe('<p>This exited the function.</p>')
  })
  test('variable', () => {
    const { frames } = interpret(`
      function get_name do
        set x to 1
        return x
      end
      get_name()
    `)
    const actual = describeFrame(frames[1], [])
    expect(actual).toBe(
      '<p>This returned the value of <code>x</code>, which in this case is <code>1</code>.</p>'
    )
  })
  test('complex option', () => {
    const { frames } = interpret(`
      function get_3 do
        return 3
      end
      function get_name do
        return get_3()
      end
      get_name()
    `)
    const actual = describeFrame(frames[1], [])
    expect(actual).toBe('<p>This returned <code>3</code>.</p>')
  })
  test('literal', () => {
    const { frames } = interpret(`
      function get_name do
        return 1
      end
      get_name()
    `)
    const actual = describeFrame(frames[0], [])
    expect(actual).toBe('<p>This returned <code>1</code>.</p>')
  })
})
const location = new Location(0, new Span(0, 0), new Span(0, 0))
const assertMarkdown = (actual, markdown) => {
  markdown = markdown
    .split('\n')
    .map((line) => line.trim())
    .join('\n')
  expect(actual).toBe(marked.parse(markdown))
}

describe.skip('SetVariableStatement', () => {
  test('standard', () => {
    const { frames } = interpret('set my_name to "Jeremy"')
    const actual = describeFrame(frames[0], [])
    expect(actual).toBe(
      '<p>This created a new variable called <code>my_name</code> and sets its value to <code>"Jeremy"</code>.</p>'
    )
  })
})

describe.skip('ChangeVariableStatement', () => {
  test('standard', () => {
    const { frames } = interpret(`
        set my_name to "Aron"
        change my_name to "Jeremy"
        `)
    const actual = describeFrame(frames[1], [])
    expect(actual).toBe(
      '<p>This updated the variable called <code>my_name</code> from...</p><pre><code>"Aron"</code></pre><p>to...</p><pre><code>"Jeremy"</code></pre>'
    )
  })
})
