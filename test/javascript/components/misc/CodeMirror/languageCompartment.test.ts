import { EditorState } from '@codemirror/state'
import type { CompletionSource } from '@codemirror/autocomplete'
import { CompletionContext } from '@codemirror/autocomplete'
import { syntaxTree } from '@codemirror/language'
import { loadLanguageCompartment } from '@/components/misc/CodeMirror/languageCompartment'

const GO_EXERCISE = [
  'package main',
  '',
  'func Welcome(name string) string {',
  '\treturn na',
  '}',
].join('\n')

async function goState() {
  return EditorState.create({
    doc: GO_EXERCISE,
    extensions: [await loadLanguageCompartment('go')],
  })
}

// Candidates come from the sources a language registers as `autocomplete`
// language data, which is what the legacy Go stream mode was missing.
async function completionsAt(state: EditorState, pos: number) {
  const sources = state.languageDataAt<CompletionSource>('autocomplete', pos)
  const options = []

  for (const source of sources) {
    const result = await source(new CompletionContext(state, pos, false))

    if (result) options.push(...result.options)
  }

  return options
}

test('go suggests names declared in the file', async () => {
  const state = await goState()
  const options = await completionsAt(state, GO_EXERCISE.indexOf('na\n') + 2)

  expect(options).toContainEqual(
    expect.objectContaining({ label: 'name', type: 'var' })
  )
})

test('go parses without errors', async () => {
  const errors: string[] = []

  syntaxTree(await goState()).iterate({
    enter: (node) => {
      if (node.type.isError) errors.push(node.name)
    },
  })

  expect(errors).toEqual([])
})
