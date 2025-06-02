import React, { useCallback, useContext } from 'react'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useAiChatStore } from './store/AiChatStore'
import { ChatContext } from '.'

export function ChatInput() {
  const [value, setValue] = React.useState('')

  const { inputRef } = useContext(ChatContext)
  const { appendMessage } = useAiChatStore()

  const handleSendOnEnter = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()

        if (value.trim() !== '') {
          appendMessage(value)
          setValue('')
        }
      }
    },
    [value, setValue]
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
        <textarea
          ref={inputRef}
          id="text"
          name="text"
          placeholder="Ask you question here"
          rows={1}
          className={assembleClassNames('chat-textarea w-full py-16 text-16')}
          value={value}
          onInput={handleInput}
          onKeyDown={handleSendOnEnter}
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
    </div>
  )
}

function QuickActionButton({ text }: { text: string }) {
  return (
    <button className="px-18 py-12 text-14 border border-[#dbdbdb] text-primaryBlue rounded-8 bg-white hover:bg-[#fafaff] leading-6">
      {text}
    </button>
  )
}

// @ts-ignore
function QuickActions() {
  const texts = ["I'd like to learn more about variables", 'Tell me more']
  return (
    <div className="flex gap-[14px] mb-[14px]">
      {texts.map((text, idx) => {
        return <QuickActionButton text={text} key={idx} />
      })}
    </div>
  )
}
