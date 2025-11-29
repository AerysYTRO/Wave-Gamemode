// Wave Radio Proxy - server.js
// Simple Express server that spawns yt-dlp to stream audio for given source URLs
// Requirements: Node.js, yt-dlp (or yt-dlp.exe) installed and available in PATH

const express = require('express')
const { spawn } = require('child_process')
const url = require('url')
const querystring = require('querystring')

const app = express()
const PORT = process.env.PORT || 3000

// /stream?url=<encoded_source>&format=mp3
app.get('/stream', (req, res) => {
  const src = req.query.url
  const fmt = req.query.format || 'mp3'

  if (!src) {
    res.status(400).send('Missing url parameter')
    return
  }

  // Validate basic URL
  try {
    const parsed = new URL(src)
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      res.status(400).send('Invalid protocol')
      return
    }
  } catch (e) {
    res.status(400).send('Invalid url')
    return
  }

  // Set response headers for audio stream
  res.setHeader('Content-Type', 'audio/mpeg')
  res.setHeader('Cache-Control', 'no-cache')

  // Spawn yt-dlp to stream best audio as mp3 to stdout
  // Command: yt-dlp -o - -f bestaudio --extract-audio --audio-format mp3 <url>

  const args = [
    src,
    '-o', '-',
    '-f', 'bestaudio',
    '--extract-audio',
    '--audio-format', fmt,
    '--no-playlist'
  ]

  const ytdlp = spawn('yt-dlp', args)

  ytdlp.stdout.pipe(res, { end: true })

  ytdlp.stderr.on('data', (data) => {
    console.error('[yt-dlp]', data.toString())
  })

  ytdlp.on('close', (code) => {
    console.log('yt-dlp exited with code', code)
    try { res.end() } catch (e) {}
  })

  ytdlp.on('error', (err) => {
    console.error('Failed to start yt-dlp:', err)
    try { res.end() } catch (e) {}
  })
})

app.get('/', (req, res) => {
  res.send('Wave Radio Proxy is running. Use /stream?url=...')
})

app.listen(PORT, () => {
  console.log('Wave Radio Proxy listening on port', PORT)
})
