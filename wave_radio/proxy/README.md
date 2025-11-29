Wave Radio Proxy
=================

Purpose
-------
This lightweight proxy converts YouTube/Spotify/other page links into a direct audio stream that MTA clients can play using `playSound(url)`.

How it works
------------
- The proxy spawns `yt-dlp` to fetch and transcode audio from a source URL and stream it to the HTTP response as MP3.
- Clients can request: `http://<proxy-host>:3000/stream?url=<encoded_source>&format=mp3`

Requirements
------------
- Node.js (v14+)
- `yt-dlp` installed and in PATH (or use `yt-dlp.exe` on Windows)
  - Installation: `pip install -U yt-dlp` or download binary from the yt-dlp releases

Install & Run
-------------
1. Install dependencies

```bash
cd wave_radio/proxy
npm install
```

2. Run the server

```bash
# Run locally on port 3000
node server.js

# or set a custom port
PORT=8080 node server.js
```

Usage from MTA
--------------
- When a player provides a YouTube/Spotify URL in-game, the server should create a proxied URL such as:

```
http://<proxy-host>:3000/stream?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D...&format=mp3
```

- The `wave_radio` server will broadcast this proxied URL to vehicle occupants; clients will call `playSound(proxiedUrl)`.

Security & Performance
----------------------
- Streaming uses CPU for transcoding; expect higher CPU usage for multiple concurrent requests.
- Consider running the proxy on a separate host with good bandwidth and a modern CPU.
- Rate-limit or require authentication if you plan to expose the proxy publicly.

Notes
-----
- This solution requires running an external process (`yt-dlp`) on the host where the proxy runs.
- For production, consider using a robust streaming pipeline (ffmpeg + caching, nginx, etc.)
- I can optionally provide a Dockerfile for easy deployment.
