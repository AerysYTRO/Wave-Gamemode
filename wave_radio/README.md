Wave Radio - In-Vehicle Radio (no HTML)

Overview
--------
This resource provides an in-vehicle radio using the native MTA GUI (no HTML/CEF). While seated in a vehicle, press SHIFT (left or right) to open the radio menu, paste a direct audio stream URL (mp3/ogg/online radio stream), then press PLAY to start playback for all occupants in the same vehicle. Use STOP to stop playback.

Important limitations
---------------------
- This resource plays only *direct audio streams* (e.g. an MP3/OGG URL or shoutcast/icecast stream). You cannot directly play a YouTube or Spotify page link with `playSound` because they are not direct audio streams.
- To play YouTube/Spotify content you'd need either:
  - An external proxy that converts YouTube/Spotify links to a direct audio stream URL (e.g., youtube-dl/yt-dlp on a server that exposes a raw MP3 stream), or
  - A CEF/HTML player (embedded browser) which the user specifically requested not to use.

Usage
-----
- Enter any vehicle, press `SHIFT` to open the radio GUI.
- Paste a stream URL in the input field, press `PLAY`.
- The driver (and all occupants) will receive the play command and attempt to play the stream locally.
- Press `STOP` to stop playback for all occupants.

Examples of working URLs
------------------------
- Direct MP3: `http://example.com/stream.mp3`
- Shoutcast/Icecast: `http://stream.example.com:8000/;stream.mp3`

Developer notes
---------------
- Server validates that the URL starts with `http://` or `https://` and does a simple heuristic check for `.mp3`, `.ogg`, or `stream` keywords.
- Playback is initiated on each client separately using `playSound(url)`. Synchronization is approximate — network delays and buffering may cause slight offsets between clients.

Files
-----
- `meta.xml` - Resource manifest
- `server.lua` - Server validation and broadcast
- `client.lua` - GUI, local playback, keybind

Security & permissions
----------------------
- The resource uses server events to broadcast play/stop to vehicle occupants.
- Admin commands `radioplay` and `radiostop` are available on server for force control.

Want YouTube/Spotify support?
------------------------------
This repository now includes a reference proxy implementation at `wave_radio/proxy/` that uses `yt-dlp` to convert YouTube/Spotify links into direct MP3 streams. To enable this feature:

1. Install and run the proxy (recommended on a separate machine or the server host):

```bash
cd wave_radio/proxy
npm install
PORT=3000 node server.js
```

2. Configure `wave_radio` to use the proxy by editing `wave_radio/server.lua` if you host the proxy on a non-default address. By default, the server will attempt to use `http://127.0.0.1:3000/stream?url=` as the proxy base URL. If your proxy runs on another host, set `PROXY_BASE` variable in `server.lua` or update the resource config.

3. In-game, paste a YouTube or Spotify link into the radio GUI and press `PLAY`. The server will construct a proxied stream URL and broadcast it to vehicle occupants; clients will play the proxied MP3 stream.

Notes & limitations:
- The proxy requires `yt-dlp` installed and will transcode/stream audio — this consumes CPU and bandwidth. Run it on a machine with sufficient resources.
- For production, consider running the proxy behind a reverse proxy, add authentication, and add caching.

If you'd like, I can generate a Dockerfile and systemd unit for the proxy, or implement the CEF approach instead. Tell me which deployment option you prefer.
