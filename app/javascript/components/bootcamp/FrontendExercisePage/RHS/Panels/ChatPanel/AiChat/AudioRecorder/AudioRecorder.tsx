import React from 'react'
import AudioVisualizer from './AudioVisualizer'
import { useAudioRecorder } from './useAudioRecorder'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { formatDuration } from './format-duration'
import { GraphicalIcon } from '@/components/common'
import { useAiChatStore } from '../store/aiChatStore'

export default function AudioRecorder() {
  const {
    isRecording,
    analyserRef,
    cancelRecording,
    liveDuration,
    startRecording,
    stopRecording,
  } = useAudioRecorder()
  const { isResponseBeingGenerated } = useAiChatStore()
  return (
    <div
      className={assembleClassNames(
        'flex items-center gap-16 ',
        isRecording && 'w-full justify-between',
        !isRecording && 'ml-auto'
      )}
    >
      {isRecording && (
        <div className="rounded-lg flex items-center gap-8">
          <button
            className="rounded-100 p-2 bg-bootcamp-very-light-purple"
            onClick={cancelRecording}
          >
            <GraphicalIcon
              className="filter-textColor6"
              icon="cross-semibold"
              width={22}
              height={22}
            />
          </button>
          <span className="w-[50px]">{formatDuration(liveDuration)}</span>
          {analyserRef.current && (
            <AudioVisualizer analyser={analyserRef.current} />
          )}
        </div>
      )}
      {isRecording ? (
        <button
          onClick={stopRecording}
          className="rounded-100 p-2 bg-textColor6"
        >
          <GraphicalIcon
            className="filter-white"
            icon="tick"
            width={22}
            height={22}
          />
        </button>
      ) : (
        <button
          className={assembleClassNames(
            'p-2 w-28 h-28 hover:bg-bootcamp-very-light-purple rounded-8',
            isResponseBeingGenerated && 'opacity-50'
          )}
          disabled={isResponseBeingGenerated}
          onClick={startRecording}
        >
          <GraphicalIcon
            className="filter-textColor6"
            icon="microphone"
            width={22}
            height={22}
          />
        </button>
      )}
    </div>
  )
}
