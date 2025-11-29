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
I can:
- Add an optional CEF-based player to embed YouTube/Spotify players (requires HTML, but provides native players), or
- Add integration instructions and a small Node + yt-dlp proxy that returns a direct audio stream URL (more advanced, needs hosting).

If you want either option, tell me which one and I will implement it.
