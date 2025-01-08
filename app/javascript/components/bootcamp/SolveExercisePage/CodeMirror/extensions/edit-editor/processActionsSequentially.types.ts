type AddContent = {
  type: 'type-out-code' | 'push-code'
  line: number
  code: string
}

type MarkLinesAsReadonly = {
  type: 'mark-lines-as-readonly'
  ranges: { from: number; to: number }[]
}

type RemoveContent = {
  type: 'remove-line-content' | 'remove-line'
  line: number
}

type BackspaceLines = {
  type: 'backspace-lines'
  from: number
  to: number
}

type HighlightCode = {
  type: 'highlight-code'
  regex: string
  ignoreCase?: boolean
  lines?: {
    from: number
    to: number
  }
}

type RemoveHighlighting = {
  type: 'remove-highlighting'
}
type RevertLinesToEditable = {
  type: 'revert-lines-to-editable'
}

type DeleteEditorContent = {
  type: 'delete-editor-content'
}

type HighlightEditorContent = {
  type: 'highlight-editor-content'
}

type PlaceCursor = {
  type: 'place-cursor'
  line: number
  char: number
}

export type EditEditorActions = {
  uuid: string
  async: boolean
  actions: (
    | AddContent
    | RemoveContent
    | BackspaceLines
    | HighlightCode
    | RemoveHighlighting
    | MarkLinesAsReadonly
    | RevertLinesToEditable
    | DeleteEditorContent
    | HighlightEditorContent
    | PlaceCursor
  )[]
}
