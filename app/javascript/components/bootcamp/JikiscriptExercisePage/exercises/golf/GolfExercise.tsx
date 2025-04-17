import type { ExecutionContext } from '@/interpreter/executor'
import DrawExercise from '../draw'
import * as Jiki from '@/interpreter/jikiObjects'

export default class GolfExercise extends DrawExercise {
  constructor() {
    super('golf')

    // Set some defaults
    this.shotLength = 0
  }

  setShotLength(_: ExecutionContext, length: number) {
    this.shotLength = length
  }
  getShotLength(_: ExecutionContext): Jiki.Number {
    return new Jiki.Number(this.shotLength)
  }
  fireFireworks(executionCtx: ExecutionContext) {
    super.fireFireworks(executionCtx, executionCtx.getCurrentTime())
  }

  // TODO: How do I get just the ones I want out of DrawExercise
  // (circle, fillColorHex, fillColorRGB, fillColorHSL)
  // and then add the new ones to this?
  public availableFunctions = [
    {
      name: 'clear',
      func: this.clear.bind(this),
      description: 'Clears the canvas.',
    },
    {
      name: 'get_shot_length',
      func: this.getShotLength.bind(this),
      description: "Returns the length of the player's shot",
    },
    {
      name: 'fire_fireworks',
      func: this.fireFireworks.bind(this),
      description: 'Fires celebratory fireworks.',
    },
    {
      name: 'circle',
      func: this.circle.bind(this),
      description:
        'It drew a circle with its center at (${arg1}, ${arg2}), and a radius of ${arg3}.',
    },
    {
      name: 'fill_color_hex',
      func: this.fillColorHex.bind(this),
      description: 'Changes the fill color using a hex string',
    },
    {
      name: 'fill_color_rgb',
      func: this.fillColorRGB.bind(this),
      description: 'Changes the fill color using red, green and blue values',
    },
    {
      name: 'fill_color_hsl',
      func: this.fillColorHSL.bind(this),
      description:
        'Changes the fill color using hue, saturation and lumisity values',
    },
  ]
}
