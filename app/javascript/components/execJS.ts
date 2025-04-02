import { generate } from 'astring'
import { parse } from 'acorn'
import { instrument } from 'aran'
import { Frame } from '@/interpreter/frames'

export const execJS = (code: string) => {
  return runCode(code)
}

function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n)
}

const runCode = (code: string) => {
  const parsedCode = parse(code, {
    sourceType: 'script',
    locations: true,
    ecmaVersion: 2024,
  })

  const extactLOCFromTag = (tag) => {
    let node = parsedCode.body
    tag
      .replace('main#$.body.', '')
      .split('.')
      .forEach((elem) => {
        if (isNumeric(elem)) {
          node = node[parseInt(elem)]
        } else {
          node = node[elem]
        }
      })
    return node.loc
  }

  const advice_global_variable = '_ARAN_ADVICE_'
  const data_global_variable = '_DATA_'

  let data = { time: 0 }
  const frames: Frame[] = []
  const describeFrame = (value) => {
    if (typeof value === 'function') {
      return String(value.name || 'anonynmous')
    } else if (typeof value === 'object' && value !== null) {
      return '#' + Object.prototype.toString.call(value).slice(8, -1)
    } else if (typeof value === 'symbol') {
      return '@' + String(value.description ?? 'unknown')
    } else if (typeof value === 'string') {
      return JSON.stringify(value)
    } else {
      return String(value)
    }
  }
  const addFrame = (
    code: string,
    status: 'SUCCESS' | 'ERROR',
    callee: any,
    location: any
  ) => {
    const time = globalThis._DATA_.time
    const line = extactLOCFromTag(location).start.line
    const frame: Frame = {
      timelineTime: time * 100,
      time: globalThis._DATA_.time,
      line: line,
      code: code,
      status: status,

      description: () => {
        return describeFrame(callee)
      },
    }
    frames.push(frame)
    globalThis._DATA_.time += 0.01
  }
  globalThis._ADD_FRAME_ = addFrame

  const advice = {
    'apply@around': (_state, callee, that, input, location) => {
      // console.log(_state, callee, that, input, location)
      const result = Reflect.apply(callee, that, input)
      globalThis._ADD_FRAME_('', 'SUCCESS', callee, location)
      return result
    },
  }

  Reflect.defineProperty(globalThis, advice_global_variable, { value: advice })
  Reflect.defineProperty(globalThis, data_global_variable, { value: {} })

  // Reset time
  globalThis._DATA_.time = 0

  const root2 = instrument(
    { kind: 'eval', path: 'main', root: parsedCode },
    { mode: 'standalone', advice_global_variable, pointcut: ['apply@around'] }
  )
  const res = globalThis.eval(generate(root2))
  console.log(res)
  return { value: res, frames: frames }
}
