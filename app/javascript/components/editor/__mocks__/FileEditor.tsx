import React from 'react'

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

export function FileEditor({
  files,
  language,
  wrap,
  theme,
  keybindings,
}): JSX.Element {
  return (
    <div>
      <p>Theme: {theme}</p>
      <p>Language: {language}</p>
      <p>Keybindings: {keybindings}</p>
      <p>Wrap: {wrap}</p>
      {files.map((file) => (
        <textarea
          key={file.filename}
          defaultValue={file.content}
          data-testid="editor-value"
        ></textarea>
      ))}
    </div>
  )
}
