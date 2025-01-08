import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useEditorStore from '../store/editorStore'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'

export function CheckScenariosButton({
  handleRunCode,
}: {
  handleRunCode: () => void
}) {
  const { shouldAutoRunCode, setShouldAutoRunCode } = useEditorStore()
  return (
    <button
      className="scenarios-button btn-primary btn-s"
      onClick={() => {
        handleRunCode()
        setShouldAutoRunCode(false)
      }}
    >
      Check Scenarios
      <GraphicalIcon
        icon="bootcamp-autorun"
        width={20}
        height={20}
        className={assembleClassNames(
          '!mx-0 !w-[20px]',
          shouldAutoRunCode ? 'invert' : ''
        )}
      />
    </button>
  )
}
