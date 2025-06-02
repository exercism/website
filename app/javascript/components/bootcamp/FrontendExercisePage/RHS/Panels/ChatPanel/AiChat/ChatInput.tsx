import React, { useCallback, useContext } from 'react'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { ChatContext } from '.'
import { useAiChatStore } from './store/aiChatStore'

export const FAKE_LONG_STREAM_MESSAGE = `<h2>Ternaries</h2>
<p>You can use ternaries in JavaScript.<br>
They follow the pattern:</p>

<pre><code class="language-javascript">conditional ? trueBranch : falseBranch; </code></pre>

<p>For example, these two pieces of code are identical in meaning:</p>

<pre><code class="language-javascript"> // if/else variant
let result;
if (something) {
  result = "Yes!";
} else {
  result = "No!";
}

// Ternary
let result = something ? "Yes!" : "No!";
</code></pre>`

export function ChatInput() {
  const [value, setValue] = React.useState('')

  const { inputRef } = useContext(ChatContext)
  const { appendMessage, streamMessage, finishStream, isMessageBeingStreamed } =
    useAiChatStore()

  const handleSendOnEnter = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()

        if (value.trim() !== '') {
          appendMessage({
            id: Date.now().toString(),
            content: value,
            sender: 'user',
            timestamp: new Date().toISOString(),
          })
          setValue('')
          demonstrateStream()
        }
      }
    },
    [value, setValue]
  )

  const demonstrateStream = useCallback(() => {
    if (value.trim() === '') return

    const words = FAKE_LONG_STREAM_MESSAGE.split(' ')
    let currentIndex = 0

    const minDelay = 100
    const maxDelay = 300

    const getRandomDelay = () =>
      Math.floor(Math.random() * (maxDelay - minDelay + 1)) + minDelay

    const streamNext = () => {
      if (currentIndex < words.length) {
        streamMessage(words[currentIndex] + ' ')
        currentIndex++
        setTimeout(streamNext, getRandomDelay())
      } else {
        finishStream()
      }
    }

    streamNext()
  }, [value])

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
          className={assembleClassNames(
            'chat-textarea w-full py-16 text-16',
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
    </div>
  )
}
