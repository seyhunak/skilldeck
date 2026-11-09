# Skilldeck explainer (16s, 1920×1080)

The source for [`docs/assets/skilldeck-explainer.mp4`](../../docs/assets/skilldeck-explainer.mp4), built with [HyperFrames](https://hyperframes.heygen.com) (HTML + GSAP rendered to video). The voiceover is ElevenLabs text-to-speech from [`vo.txt`](vo.txt), saved as `assets/vo.mp3`.

```bash
cd video/explainer && npm run dev
```

```bash
cd video/explainer && npm run check && npm run render
```

To regenerate the voiceover, put `ELEVENLABS_API_KEY` in the repo-root `.env` (git-ignored) and synthesize `vo.txt` with any ElevenLabs voice. If the speech length changes, retime the beats in `index.html`.
