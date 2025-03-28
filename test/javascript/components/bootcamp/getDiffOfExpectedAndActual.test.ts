import { getDiffOfExpectedAndActual } from '@/components/bootcamp/JikiscriptExercisePage/TestResultsView/useInspectedTestResultView'

test('handles commas correctly', async () => {
  const right = 'One for me, one for you!'
  const wrong = 'One for me ,one for you!'

  const diff = getDiffOfExpectedAndActual(false, right, wrong)
  const expected = [
    { count: 11, added: false, removed: false, value: '"One for me' },
    { count: 1, added: false, removed: true, value: ',' },
    { count: 1, added: false, removed: false, value: ' ' },
    { count: 1, added: true, removed: false, value: ',' },
    { count: 13, added: false, removed: false, value: 'one for you!"' },
  ]
  expect(diff).toEqual(expected)
})

test('handles booleans correctly', async () => {
  const right = true
  const wrong = false

  const diff = getDiffOfExpectedAndActual(false, right, wrong)
  const expected = [
    { added: false, count: 1, removed: true, value: 'true' },
    { added: true, count: 1, removed: false, value: 'false' },
  ]
  expect(diff).toEqual(expected)
})
