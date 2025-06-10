import React, { useCallback, useContext } from 'react'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { ChatContext } from '.'
import { Message, useAiChatStore } from './store/aiChatStore'
import AudioRecorder from './AudioRecorder/AudioRecorder'
import { useAiStream } from './useAiStream'

export function ChatInput() {
  const [value, setValue] = React.useState('')
  const { inputRef, links, solutionUuid, userId } = useContext(ChatContext)

  const {
    appendMessage,
    streamMessage,
    finishStream,
    isMessageBeingStreamed,
    setIsResponseBeingGenerated,
    isResponseBeingGenerated,
  } = useAiChatStore()

  useAiStream(streamMessage)

  const handleSendOnEnter = useCallback(
    async (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()

        if (value.trim() === '') return

        const userMessage: Message = {
          id: Date.now().toString(),
          content: value,
          sender: 'user',
          timestamp: new Date().toISOString(),
        }

        appendMessage(userMessage)
        setValue('')

        try {
          await fetch(links.apiBootcampSolutionChat, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              solution_uuid: solutionUuid,
              content: value,
            }),
          })
          // setIsResponseBeingGenerated(true)
        } catch (err) {
          console.error('AI response error:', err)
          finishStream()
        }
      }
    },
    [value]
  )

  const handleInput = useCallback(
    (e: React.ChangeEvent<HTMLTextAreaElement>) => {
      setValue(e.target.value)
    },
    [setValue]
  )

  return (
    <div className="bg-white shadow-msg-container relative px-24 py-20 z-5">
      <div className="chat-input-container">
        <div className="flex w-full items-center">
          <textarea
            ref={inputRef}
            id="text"
            name="text"
            placeholder={
              isResponseBeingGenerated
                ? 'Generating response...'
                : isMessageBeingStreamed
                ? 'Streaming response...'
                : 'Ask anything'
            }
            rows={1}
            className={assembleClassNames(
              'chat-textarea w-full text-16',
              isMessageBeingStreamed && 'opacity-50',
              isResponseBeingGenerated && 'animate-blink'
            )}
            value={value}
            onInput={handleInput}
            onKeyDown={handleSendOnEnter}
            disabled={isMessageBeingStreamed || isResponseBeingGenerated}
          />

          {value.length > 0 && (
            <button
              className={assembleClassNames('p-2 w-28 h-28 shrink-0')}
              type="submit"
            >
              <GraphicalIcon
                className="filter-textColor6"
                icon="enter"
                height={24}
                width={24}
              />
            </button>
          )}
        </div>
        <AudioRecorder />
      </div>
    </div>
  )
}
