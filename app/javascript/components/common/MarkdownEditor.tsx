import React from 'react'
import SimpleMDE from 'react-simplemde-editor'
import 'easymde/dist/easymde.min.css'

export const MarkdownEditor = ({ uuid }: { uuid: string }): JSX.Element => (
  <SimpleMDE
    options={{
      autosave: { enabled: true, uniqueId: uuid },
      indentWithTabs: false,
      toolbar: [
        'heading',
        'bold',
        'italic',
        'code',
        'link',
        'unordered-list',
        'ordered-list',
        'fullscreen',
      ],
      status: ['autosave'],
    }}
  />
)
