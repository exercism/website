import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

test('literal', () => {
  const { frames } = interpret('log "Jeremy"')
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This logged <code>"Jeremy"</code>.</p>
     <hr/>
     <h3>Steps Jiki Took</h3>
     <ul>
      <li>Jiki wrote <code>"Jeremy"</code> here for you!</li>
    </ul>`
  )
})

test('function', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('log get_name()', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This logged <code>"Jeremy"</code>.</p>
     <hr/>
     <h3>Steps Jiki Took</h3>
     <ul>
      <li>Jiki used the <code>get_name()</code> function which returned <code>"Jeremy"</code>.</li>
      <li>Jiki wrote <code>"Jeremy"</code> here for you!</li>
    </ul>`
  )
})

test('binary comparison', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('log 5 > 3', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This logged <code>true</code>.</p>
    <hr/>
    <h3>Steps Jiki Took</h3>
    <ul>
      <li>Jiki evaluated <code>5 > 3</code> and determined it was <code>true</code>.</li>
     <li>Jiki wrote <code>true</code> here for you!</li>
   </ul>`
  )
})

test.skip('binary comparison', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('set my_name to true and false', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This created a new variable called<code>my_name</code>and set its value to <code>false</code>.</p>`
  )
})
