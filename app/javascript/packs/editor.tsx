import React from 'react'
import { initReact } from '../utils/react-bootloader.jsx'

import '../../css/pages/editor'
import '../../css/modals/editor-hints'

import { Assignment, Submission } from '../components/editor/types'
import { Editor, EditorConfig } from '../components/Editor'

import { camelizeKeys } from 'humps'
function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  editor: (data: any) => (
    <Editor
      endpoint={data.endpoint}
      initialSubmission={camelizeKeysAs<Submission>(data.submission)}
      files={data.files}
      tests={data.tests}
      highlightJSLanguage={data.highlightjs_language}
      averageTestDuration={data.average_test_duration}
      exercisePath={data.exercise_path}
      trackTitle={data.track_title}
      trackSlug={data.track_slug}
      exerciseTitle={data.exercise_title}
      introduction={data.introduction}
      assignment={camelizeKeysAs<Assignment>(data.assignment)}
      exampleFiles={data.example_files}
      storageKey={data.storage_key}
      debuggingInstructions={data.debugging_instructions}
      config={camelizeKeysAs<EditorConfig>(data.config)}
    />
  ),
})
