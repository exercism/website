import { emojis } from '../setupHelpers/emoji'
import { honorifics } from '../setupHelpers/honorifics'

export const genericSetupFunctions = {
  join: (...args: any[]) => args.join(''),
  randomEmoji: () => randomItem(emojis),
  randomHonorific: () => randomItem(honorifics),
}

const randomItem = (list) => list[Math.floor(Math.random() * list.length)]
