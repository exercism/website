import React, { useMemo, useRef, useState } from 'react'
import { TrackSelect } from '../common/TrackSelect'
import { ExerciseIcon } from '../common'

type Exercise = {
  slug: string
  title: string
  iconUrl: string
  url: string
}

type Track = {
  slug: string
  title: string
  iconUrl: string
  exercises: readonly Exercise[]
}

// Picks a track with a client-side test runner, then one of its exercises,
// and opens that exercise in the experimental editor.
export default function ExperimentalEditorPicker({
  tracks,
}: {
  tracks: readonly Track[]
}): JSX.Element {
  const [track, setTrack] = useState<Track>(tracks[0])
  const [exercise, setExercise] = useState<Exercise | null>(null)
  const [query, setQuery] = useState('')
  const [open, setOpen] = useState(false)
  const [highlighted, setHighlighted] = useState(0)
  const inputRef = useRef<HTMLInputElement>(null)

  const matches = useMemo(() => {
    const q = query.trim().toLowerCase()
    if (q.length === 0) return track.exercises

    return track.exercises.filter(
      (e) => e.title.toLowerCase().includes(q) || e.slug.includes(q)
    )
  }, [query, track])

  const changeTrack = (newTrack: Track) => {
    setTrack(newTrack)
    setExercise(null)
    setQuery('')
    setHighlighted(0)
  }

  const choose = (chosen: Exercise) => {
    setExercise(chosen)
    setQuery(chosen.title)
    setOpen(false)
  }

  // A full page load, because the editor needs cross-origin isolation,
  // which the browser only grants on a real navigation.
  const openEditor = () => {
    if (exercise) window.location.assign(exercise.url)
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setOpen(true)
      setHighlighted((i) => Math.min(i + 1, matches.length - 1))
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setHighlighted((i) => Math.max(i - 1, 0))
    } else if (e.key === 'Enter') {
      e.preventDefault()
      if (open && matches[highlighted]) {
        choose(matches[highlighted])
      } else {
        openEditor()
      }
    } else if (e.key === 'Escape') {
      setOpen(false)
    }
  }

  return (
    <div className="c-admin-experimental-editor-picker">
      <div className="field">
        <label>Language</label>
        <TrackSelect<Track>
          tracks={tracks}
          value={track}
          setValue={changeTrack}
        />
      </div>

      <div className="field exercise">
        <label htmlFor="experimental-editor-exercise">Exercise</label>
        <div className="combobox">
          <input
            id="experimental-editor-exercise"
            ref={inputRef}
            type="text"
            role="combobox"
            aria-expanded={open}
            aria-controls="experimental-editor-exercises"
            autoComplete="off"
            spellCheck={false}
            placeholder={`Search ${track.exercises.length} exercises`}
            value={query}
            onChange={(e) => {
              setQuery(e.target.value)
              setExercise(null)
              setHighlighted(0)
              setOpen(true)
            }}
            onFocus={() => setOpen(true)}
            onBlur={() => setOpen(false)}
            onKeyDown={handleKeyDown}
          />
          {open ? (
            <ul id="experimental-editor-exercises" role="listbox">
              {matches.length === 0 ? (
                <li className="empty">No exercises match</li>
              ) : (
                matches.map((e, i) => (
                  <li
                    key={e.slug}
                    role="option"
                    aria-selected={i === highlighted}
                    className={i === highlighted ? 'highlighted' : ''}
                    onMouseEnter={() => setHighlighted(i)}
                    // mousedown, so the choice lands before the input blurs
                    onMouseDown={(event) => {
                      event.preventDefault()
                      choose(e)
                    }}
                  >
                    <ExerciseIcon iconUrl={e.iconUrl} />
                    <span className="title">{e.title}</span>
                    <span className="slug">{e.slug}</span>
                  </li>
                ))
              )}
            </ul>
          ) : null}
        </div>
      </div>

      <button
        type="button"
        className="btn-primary btn-m"
        disabled={!exercise}
        onClick={openEditor}
      >
        Open
      </button>
    </div>
  )
}
