import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useEditorStore from '../store/editorStore'

export function CheckScenariosButton({
  handleRunCode,
}: {
  handleRunCode: () => void
}) {
  const { toggleShouldAutoRunCode, shouldAutoRunCode, setShouldAutoRunCode } =
    useEditorStore()
  return (
    <div
      className="bg-jiki-purple text-slate-200 font-semibold p-4 rounded-5 flex items-center gap-4 hover:cursor-pointer"
      onClick={() => {
        handleRunCode()
        setShouldAutoRunCode(false)
      }}
    >
      Check Scenarios
      <button
        onClick={(e) => {
          e.stopPropagation()
          toggleShouldAutoRunCode()
        }}
        className={assembleClassNames(
          shouldAutoRunCode
            ? 'bg-[#4A0AC2] font-semibold p-4 rounded-5'
            : 'bg-[#D8C5FC] font-semibold p-4 rounded-5'
        )}
      >
        <img
          src="/autorun.svg"
          alt=""
          width={14}
          height={14}
          className={assembleClassNames(
            'p-[-8px]',
            shouldAutoRunCode ? 'invert' : ''
          )}
        />
      </button>
    </div>
  )
}
