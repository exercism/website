import React, { useState, useCallback } from 'react'
import { Accordion } from '../../common/Accordion'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Avatar } from '../../common/Avatar'
import { Icon } from '../../common/Icon'

export const Guidance = (): JSX.Element => {
  const [accordionState, setAccordionState] = useState([
    {
      id: 'notes',
      isOpen: true,
    },
    {
      id: 'solution',
      isOpen: false,
    },
    {
      id: 'feedback',
      isOpen: false,
    },
  ])

  const handleClick = useCallback(
    (id: string) => {
      setAccordionState(
        accordionState.map((state) => {
          return {
            id: state.id,
            isOpen: id === state.id,
          }
        })
      )
    },
    [accordionState]
  )

  const isOpen = useCallback(
    (id: string) => {
      const state = accordionState.find((state) => state.id === id)

      if (!state) {
        throw new Error('Accordion id not found')
      }

      return state.isOpen
    },
    [accordionState]
  )

  return (
    <>
      <Accordion id="notes" isOpen={isOpen('notes')} onClick={handleClick}>
        <Accordion.Header>Mentor notes</Accordion.Header>
        <Accordion.Panel>
          <div className="c-textual-content --small">
            {/* TODO: REPLACE THIS */}
            <h3>Talking points</h3>
            <ul>
              <li>
                <code>each_cons</code> instead of an iterator{' '}
                <code>with_index</code>: In Ruby, you rarely have to write
                iterators that need to keep track of the index. Enumerable has
                powerful methods that do that for us.
              </li>
              <li>
                <code>chars</code>: instead of <code>split('')</code>.
              </li>
              <li>
                <code>each_char</code>: if an <code>Array</code> is not
                specifically necessary or wanted.
              </li>
              <li>
                <code>attr_reader</code>: instead of the instance variable,{' '}
                <a
                  href="https://ivoanjo.me/blog/2017/09/20/why-i-always-use-attr_reader-to-access-instance-variables"
                  target="_blank"
                >
                  explained here
                </a>
                .
              </li>
              <li>
                <code>private</code> attr_reader: Following the 'rule' for
                encapsulation: if it doesn't need to be public, make it private.{' '}
                <a
                  href="http://ruby-for-beginners.rubymonstas.org/writing_classes/state_and_behaviour.html"
                  target="_blank"
                >
                  This link
                </a>{' '}
                may come in handy for a first introduction.
              </li>
              <li>
                <code>unless</code>, inline: With <code>unless</code> instead of{' '}
                <code>if</code>, we can show what "good" looks like for the
                conditional statement.
              </li>
              <li>
                <code>error</code>: Custom error message? (Only if the first
                submission meets the Minimal Solution.)
              </li>
              <li>
                <code>map(&amp;:join)</code>: instead of map with block, but at
                this point in the track it's okay to just accept it if students
                use it, no need to require it or dive into the subject of{' '}
                <code>Symbol#to_proc</code>.
              </li>
              <li>
                <code>each_char</code>: may be preferable over{' '}
                <code>chars</code> as it returns an <code>Enumerator</code> that
                will yield each character without creating an intermediate{' '}
                <code>Array</code>. More: <code>String#chars</code> with a block
                has a deprecation warning in more recent Ruby versions.{' '}
                <code>str.chars</code> is a shorthand for{' '}
                <code>str.each_char.to_a</code>.
              </li>
            </ul>
            <h3>Mentor Research</h3>
            <ul>
              <li>
                The Iteration article mentioned above isn't ideal, but it's one
                of the few I know of that does more than comparing{' '}
                <code>each</code> and <code>map</code>, PLUS don't uses hashes
                for examples. Other suggestions welcome.
              </li>
              <li>
                <code>each_cons</code> raises an ArgumentError for arguments
                &lt;= 0; it returns the array if the argument &gt;= the array.
              </li>
            </ul>
            {/* TODO: END REPLACE */}
          </div>
        </Accordion.Panel>
      </Accordion>
      <Accordion
        id="solution"
        isOpen={isOpen('solution')}
        onClick={handleClick}
      >
        <Accordion.Header>How you solved the exercise</Accordion.Header>
        <Accordion.Panel>
          {/* TOOD: Replace "#" with mentor_solution.web_url */}
          <a href="#" className="c-published-solution">
            <header className="--header">
              <div className="--exercise">
                {/* TODO: Replace with mentor.handle and mentor.avatar_url */}
                <Avatar
                  handle="iHiD"
                  src="https://avatars2.githubusercontent.com/u/5337876?s=460&v=4"
                />

                <div className="--info">
                  <div className="--exercise-title">Your Solution</div>
                  {/* TODO: Replace "Leap" and "Ruby" */}
                  <div className="--track-title">to Leap in Ruby</div>
                </div>

                {/*TODO: If mentor_solution.published_at? */}
                <div className="--counts">
                  <div className="--count">
                    <Icon
                      icon="star"
                      alt="Number of times solution has been stared"
                    />
                    {/*TODO: Replace with num_stars */}
                    <div className="--num">10</div>
                  </div>
                  <div className="--count">
                    <Icon
                      icon="comment"
                      alt="Number of times solution has been commented on"
                    />
                    {/*TODO: Replace with num_comments */}
                    <div className="--num">2</div>
                  </div>
                </div>
              </div>
            </header>
            <pre>
              {/* TODO: Replcae with mentor_solution.snippet */}
              <code className="language-csharp hljs">
                <span className="hljs-keyword">public</span>{' '}
                <span className="hljs-keyword">class</span>{' '}
                <span className="hljs-title">Year</span>
                <span className="hljs-function">
                  <span className="hljs-keyword">public</span>{' '}
                  <span className="hljs-keyword">static</span>{' '}
                  <span className="hljs-built_in">bool</span>{' '}
                  <span className="hljs-title">IsLeap</span>(
                  <span className="hljs-params">
                    <span className="hljs-built_in">int</span> year
                  </span>
                  )
                </span>
                <span className="hljs-keyword">if</span> (year %{' '}
                <span className="hljs-number">4</span> !={' '}
                <span className="hljs-number">0</span>){' '}
                <span className="hljs-keyword">return</span>{' '}
                <span className="hljs-function">
                  <span className="hljs-literal">false</span>
                  <span className="hljs-title">if</span> (
                  <span className="hljs-params">
                    year % <span className="hljs-number">100</span> =={' '}
                    <span className="hljs-number">0</span> &amp;&amp; year %{' '}
                    <span className="hljs-number">400</span>
                  </span>
                  ) <span className="hljs-keyword">return</span>{' '}
                  <span className="hljs-literal">false</span>
                  <span className="hljs-keyword">return</span>{' '}
                  <span className="hljs-literal">true</span>
                </span>
                ;
              </code>
            </pre>
            <footer className="--footer">
              <div className="locs">
                <GraphicalIcon icon="loc" />
                {/* TODO: Replace with mentor_solution.num_loc */}
                <div className="num">9 lines</div>
              </div>
            </footer>
          </a>
        </Accordion.Panel>
      </Accordion>
      <Accordion
        id="feedback"
        isOpen={isOpen('feedback')}
        onClick={handleClick}
      >
        <Accordion.Header>Automated feedback</Accordion.Header>
        <Accordion.Panel>
          <p>Feedback here</p>
        </Accordion.Panel>
      </Accordion>
    </>
  )
}
