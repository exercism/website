import * as monaco from 'monaco-editor/esm/vs/editor/editor.api'

export const setupThemes = (): void => {
  monaco.editor.defineTheme(Themes.LIGHT, {
    base: 'vs',
    inherit: true,
    rules: [],
    colors: {
      'editor.foreground': '#000000',
      'editor.background': '#EDF9FA',
      'editorCursor.foreground': '#8B0000',
      'editor.lineHighlightBackground': '#0000FF20',
      'editorLineNumber.foreground': '#008800',
      'editor.selectionBackground': '#88000030',
      'editor.inactiveSelectionBackground': '#88000015',
    },
  })

  monaco.editor.defineTheme(Themes.DARK, {
    base: 'vs-dark',
    inherit: true,
    rules: [],
    colors: {},
  })
}
