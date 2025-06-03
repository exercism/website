import { useState, useRef, useContext, useCallback } from 'react'
import { v4 as uuid } from 'uuid'
import { ChatContext } from '..'

export type AudioRecorderProps = ReturnType<typeof useAudioRecorder>

export function useAudioRecorder() {
  const [isRecording, setIsRecording] = useState(false)
  const [liveDuration, setLiveDuration] = useState(0)

  const mediaRecorderRef = useRef<MediaRecorder | null>(null)
  const audioContextRef = useRef<AudioContext | null>(null)
  const timerRef = useRef<NodeJS.Timeout | null>(null)
  const streamRef = useRef<MediaStream | null>(null)
  const audioChunksRef = useRef<BlobPart[]>([])

  const { analyserRef } = useContext(ChatContext)

  const cleanup = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current)
      timerRef.current = null
    }

    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop())
      streamRef.current = null
    }

    if (audioContextRef.current) {
      audioContextRef.current.close()
      audioContextRef.current = null
    }

    if (analyserRef?.current) {
      analyserRef.current = null
    }

    mediaRecorderRef.current = null
    audioChunksRef.current = []
    setLiveDuration(0)
  }, [analyserRef])

  const startTimer = useCallback(() => {
    setLiveDuration(0)
    timerRef.current = setInterval(() => {
      setLiveDuration((prev) => prev + 1)
    }, 1000)
  }, [])

  const stopTimer = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current)
      timerRef.current = null
    }
  }, [])

  const processRecording = useCallback(() => {
    const chunks = audioChunksRef.current
    if (chunks.length === 0) return

    const mimeType = mediaRecorderRef.current?.mimeType || 'audio/webm'
    const audioBlob = new Blob(chunks, { type: mimeType })
    const formData = new FormData()
    formData.append('audio', audioBlob)

    console.log({
      audio: formData,
      uuid: uuid(),
      size: audioBlob.size,
      duration: liveDuration,
    })
  }, [liveDuration])

  const startRecording = useCallback(async (): Promise<void> => {
    if (
      !navigator.mediaDevices?.getUserMedia ||
      typeof MediaRecorder === 'undefined'
    ) {
      alert('Your browser does not support audio recording.')
      return
    }

    if (isRecording) return

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      })
      streamRef.current = stream

      if (!audioContextRef.current) {
        audioContextRef.current = new AudioContext()
        await audioContextRef.current.resume()
      }

      const source = audioContextRef.current.createMediaStreamSource(stream)
      const analyser = audioContextRef.current.createAnalyser()
      analyser.fftSize = 256
      analyserRef.current = analyser
      source.connect(analyser)

      const mediaRecorder = new MediaRecorder(stream, {
        mimeType: MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
          ? 'audio/webm;codecs=opus'
          : undefined,
      })
      mediaRecorderRef.current = mediaRecorder

      audioChunksRef.current = []

      mediaRecorder.ondataavailable = (event: BlobEvent) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data)
        }
      }

      mediaRecorder.onerror = (event) => {
        console.error('MediaRecorder error:', event)
        setIsRecording(false)
        stopTimer()
        cleanup()
      }

      // collect data every 100ms
      mediaRecorder.start(100)
      setIsRecording(true)
      startTimer()
    } catch (err: any) {
      console.error('Recording error:', err)

      if (err.name === 'NotAllowedError') {
        alert(
          'Microphone access denied. Please allow microphone access and try again.'
        )
      } else if (err.name === 'NotFoundError') {
        alert('No microphone found. Please connect a microphone and try again.')
      } else if (err.name === 'NotReadableError') {
        alert('Microphone is being used by another application.')
      } else {
        alert('Failed to start recording. Please try again.')
      }

      cleanup()
    }
  }, [isRecording, analyserRef, startTimer, stopTimer, cleanup])

  const stopRecording = useCallback((): Promise<void> => {
    return new Promise((resolve) => {
      const recorder = mediaRecorderRef.current
      if (!recorder || recorder.state === 'inactive' || !isRecording) {
        resolve()
        return
      }

      recorder.onstop = () => {
        setIsRecording(false)
        stopTimer()

        processRecording()

        cleanup()
        resolve()
      }

      try {
        recorder.stop()
      } catch (err) {
        console.error('Error stopping recorder:', err)
        setIsRecording(false)
        stopTimer()
        cleanup()
        resolve()
      }
    })
  }, [isRecording, stopTimer, processRecording, cleanup])

  const cancelRecording = useCallback((): void => {
    const recorder = mediaRecorderRef.current

    if (recorder && recorder.state !== 'inactive') {
      recorder.onstop = () => {
        setIsRecording(false)
        stopTimer()
        cleanup()
      }

      try {
        recorder.stop()
      } catch (err) {
        console.error('Error stopping recorder:', err)
        setIsRecording(false)
        stopTimer()
        cleanup()
      }
    } else {
      setIsRecording(false)
      stopTimer()
      cleanup()
    }
  }, [stopTimer, cleanup])

  return {
    startRecording,
    stopRecording,
    cancelRecording,
    isRecording,
    liveDuration,
    analyserRef,
  }
}
