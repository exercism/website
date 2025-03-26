import React from 'react'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { Icon } from '@/components/common'
import { GraphicalIcon } from '@/components/common'

export function WhoIsThisTrackForRHS(): JSX.Element {
  return (
    <div className="rhs" data-capy-element="who-is-this-track-for-rhs">
      <div className="rounded-8 p-20 bg-backgroundColorD border-1 border-borderColor7 mb-16">
        <div className="flex flex-row gap-8 items-center justify-center text-16 text-textColor1 mb-16">
          <Icon
            icon="exercism-face"
            className="filter-textColor1"
            alt="exercism-face"
            height={16}
            width={16}
          />
          <div>
            Exercism's
            <strong className="font-semibold"> Coding Fundamentals</strong>
          </div>
        </div>
        <VimeoEmbed className="rounded-8 mb-16" id="1068683543?h=2de237a304" />
        <div className="text-16 leading-150 text-textColor2">
          <p className="mb-12 text-17 font-semibold">The course offers:</p>
          <ul className="flex flex-col gap-8 text-16 font-regular">
            <li className="flex items-start">
              <GraphicalIcon
                icon="wave"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <span>
                <strong className="font-semibold">Expert teaching</strong> and
                mentoring support.
              </span>
            </li>
            <li className="flex items-start">
              <GraphicalIcon
                icon="fun"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <span>
                Over{' '}
                <strong className="font-semibold">
                  100 hours of hands-on project based learning
                </strong>
                , making games and solving puzzles.
              </span>
            </li>
            <li className="flex items-start">
              <GraphicalIcon
                icon="complete"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <span>
                A{' '}
                <strong className="font-semibold">
                  complete Learn to Code syllabus
                </strong>{' '}
                covering coding basics, functions, object oriented programming,
                and the coder's mindset.
              </span>
            </li>
            <li className="flex items-start">
              <GraphicalIcon
                icon="certificate"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <span>
                A formal <strong className="font-semibold">certificate</strong>{' '}
                on completion.
              </span>
            </li>
          </ul>
        </div>
      </div>
    </div>
  )
}
