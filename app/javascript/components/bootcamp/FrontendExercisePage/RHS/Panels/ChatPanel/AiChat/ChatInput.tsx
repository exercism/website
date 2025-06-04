import React, { useCallback, useContext } from 'react'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { ChatContext } from '.'
import { Message, useAiChatStore } from './store/aiChatStore'
import AudioRecorder from './AudioRecorder/AudioRecorder'
import { API_KEY, useGeminiLive } from './useGeminiLive'

export function ChatInput() {
  const [value, setValue] = React.useState('')
  const { inputRef } = useContext(ChatContext)
  const { appendMessage, streamMessage, finishStream, isMessageBeingStreamed } =
    useAiChatStore()

  const { sendMessage, getNextTurn } = useGeminiLive(API_KEY)

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
          sendMessage(value)

          const turns = await getNextTurn()
          for (const turn of turns) {
            console.log('turn', turn)
            if (turn.text) {
              streamMessage(turn.text)
            } else if (turn.data) {
              streamMessage(turn.data)
            }
          }

          finishStream()
        } catch (err) {
          console.error('AI response error:', err)
          finishStream()
        }
      }
    },
    [value, sendMessage, getNextTurn]
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
            placeholder="Ask your question here"
            rows={1}
            className={assembleClassNames(
              'chat-textarea w-full text-16',
              isMessageBeingStreamed && 'opacity-50'
            )}
            value={value}
            onInput={handleInput}
            onKeyDown={handleSendOnEnter}
            disabled={isMessageBeingStreamed}
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
