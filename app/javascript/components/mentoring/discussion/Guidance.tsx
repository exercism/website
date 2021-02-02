import React, { useState, useCallback } from 'react'
import { Accordion } from '../../common/Accordion'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Avatar } from '../../common/Avatar'
import { Icon } from '../../common/Icon'
import { MentorNotes } from './MentorNotes'

export const Guidance = ({ notes }: { notes: string }): JSX.Element => {
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
          const isOpen = id === state.id && !state.isOpen
          return {
            id: state.id,
            isOpen: isOpen,
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
          <MentorNotes notes={notes} />
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
