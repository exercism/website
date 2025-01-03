import React from 'react'
import { useContext } from 'react'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'

export function PassMessage({ testIdx }: { testIdx: number }) {
  const {
    exercise: {
      config: { title },
    },
  } = useContext(SolveExercisePageContext)
  return (
    <h3 className="text-xl font-bold">
      {congratsMessages[stringToHash(title, testIdx)]}
    </h3>
  )
}

// function seededRandom(seed: number): () => number {
//   const MAX = 2147483647;
//   let s = seed % MAX;
//   return () => {
//     s = (s * 16807) % MAX;
//     return (s - 1) / (MAX - 1);
//   };
// }

// function shuffle<T>(array: T[], seed: number): T[] {
//   const random = seededRandom(seed);
//   const result = array.slice();
//   for (let i = result.length - 1; i > 0; i--) {
//     const j = Math.floor(random() * (i + 1));
//     [result[i], result[j]] = [result[j], result[i]];
//   }
//   return result;
// }

function stringToHash(input: string, testIdx: number): number {
  const PRIME = 31
  let hash = 0

  for (let i = 0; i < input.length; i++) {
    hash =
      (hash * PRIME + input.charCodeAt(i) + testIdx) % congratsMessages.length
  }

  return hash
}

// ty djipity
const congratsMessages = [
  'Well done!',
  'Nice work!',
  'Fantastic job!',
  'Amazing effort!',
  'Great achievement!',
  'Congratulations!',
  "You're awesome!",
  'Keep it up!',
  'Way to go!',
  'Outstanding performance!',
  'Impressive skills!',
  'Bravo!',
  'Excellent work!',
  'You nailed it!',
  'Top-notch effort!',
  'Remarkable job!',
  'You crushed it!',
  'Phenomenal work!',
  "You're a star!",
  'Keep shining!',
  'Exceptional performance!',
  'Amazing dedication!',
  'You did it!',
  'Superb work!',
  'Hats off to you!',
  "You're incredible!",
  'Keep soaring!',
  'Great going!',
  'Terrific job!',
  'Wonderful effort!',
  "You're on fire!",
  'Unbelievable talent!',
  "You're unstoppable!",
  "You're a rockstar!",
  'Keep up the amazing work!',
  'A round of applause!',
  'Spectacular work!',
  'Fantastic accomplishment!',
  "You're the best!",
  'Brilliant job!',
  'Incredible achievement!',
  "You're crushing it!",
  'Keep the momentum going!',
  "You're a legend!",
  "You're extraordinary!",
  'Superb achievement!',
  'Kudos to you!',
  "You're one of a kind!",
  "You're making it happen!",
  'What a pro!',
  'You deserve it!',
  "You're unstoppable!",
  "You're an inspiration!",
  "You're amazing!",
  'Keep the streak alive!',
  "You're shining bright!",
  "You're unbeatable!",
  "You're making waves!",
  'You outdid yourself!',
  "You're a winner!",
  "You're phenomenal!",
  "You're absolutely brilliant!",
  "You're unstoppable!",
  'Keep dazzling us!',
  "You're one in a million!",
  'You set the bar high!',
  "You're achieving greatness!",
  "You're a true champion!",
  "You're awe-inspiring!",
  'Keep blazing trails!',
  "You're making history!",
  "You're exceptional!",
  "You're a visionary!",
  "You're lighting up the path!",
  "You're raising the standard!",
  "You're beyond amazing!",
  "You're truly gifted!",
  "You're unmatched!",
  "You're redefining success!",
  "You're a trendsetter!",
  "You're at the top of your game!",
  "You're magnificent!",
  "You're unstoppable!",
  "You're writing your legacy!",
  "You're an overachiever!",
  "You're a miracle worker!",
  "You're sensational!",
  "You're pure excellence!",
  "You're radiating greatness!",
  "You're a standout!",
  "You're turning heads!",
  "You're rewriting the rules!",
  "You're redefining awesome!",
  "You're showing the way!",
  "You're world-class!",
  "You're leading the charge!",
  "You're unstoppable magic!",
]
