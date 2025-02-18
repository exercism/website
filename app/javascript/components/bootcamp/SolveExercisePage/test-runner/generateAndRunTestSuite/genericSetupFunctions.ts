import { emojis } from '../setupHelpers/emoji'
import { honorifics } from '../setupHelpers/honorifics'

export function randomEmoji() {
  return randomItem(emojis)
}
const randomItem = (list) => list[Math.floor(Math.random() * list.length)]

export const genericSetupFunctions = {
  join: (...args: any[]) => args.join(''),
  randomEmoji: randomEmoji,
  randomHonorific: () => randomItem(honorifics),
}
