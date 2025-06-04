export function mergeInt16Arrays(chunks: Int16Array[]): Int16Array {
  const total = chunks.reduce((sum, chunk) => sum + chunk.length, 0)
  const merged = new Int16Array(total)
  let offset = 0
  for (const chunk of chunks) {
    merged.set(chunk, offset)
    offset += chunk.length
  }
  return merged
}

export function encodeWAV(
  samples: Int16Array,
  sampleRate: number
): ArrayBuffer {
  const buffer = new ArrayBuffer(44 + samples.length * 2)
  const view = new DataView(buffer)

  const writeString = (offset: number, str: string) => {
    for (let i = 0; i < str.length; i++) {
      view.setUint8(offset + i, str.charCodeAt(i))
    }
  }

  writeString(0, 'RIFF')
  view.setUint32(4, 36 + samples.length * 2, true)
  writeString(8, 'WAVE')
  writeString(12, 'fmt ')
  view.setUint32(16, 16, true)
  view.setUint16(20, 1, true)
  view.setUint16(22, 1, true)
  view.setUint32(24, sampleRate, true)
  view.setUint32(28, sampleRate * 2, true)
  view.setUint16(32, 2, true)
  view.setUint16(34, 16, true)
  writeString(36, 'data')
  view.setUint32(40, samples.length * 2, true)

  let offset = 44
  for (let i = 0; i < samples.length; i++, offset += 2) {
    view.setInt16(offset, samples[i], true)
  }

  return buffer
}

export function convertToPCM16(float32Array: Float32Array): Int16Array {
  const pcm = new Int16Array(float32Array.length)
  for (let i = 0; i < float32Array.length; i++) {
    const s = Math.max(-1, Math.min(1, float32Array[i]))
    pcm[i] = s < 0 ? s * 0x8000 : s * 0x7fff
  }
  return pcm
}

export async function resampleAudioBuffer(
  buffer: AudioBuffer,
  targetSampleRate: number
): Promise<AudioBuffer> {
  const offlineCtx = new OfflineAudioContext(
    1, // mono
    Math.ceil(buffer.duration * targetSampleRate),
    targetSampleRate
  )

  const source = offlineCtx.createBufferSource()
  const monoBuffer =
    buffer.numberOfChannels === 1 ? buffer : mergeToMono(buffer)

  source.buffer = monoBuffer
  source.connect(offlineCtx.destination)
  source.start(0)

  return offlineCtx.startRendering()
}

function mergeToMono(buffer: AudioBuffer): AudioBuffer {
  const output = new AudioContext().createBuffer(
    1,
    buffer.length,
    buffer.sampleRate
  )

  const channelData = output.getChannelData(0)
  for (let i = 0; i < buffer.numberOfChannels; i++) {
    const input = buffer.getChannelData(i)
    for (let j = 0; j < input.length; j++) {
      channelData[j] += input[j] / buffer.numberOfChannels
    }
  }

  return output
}
