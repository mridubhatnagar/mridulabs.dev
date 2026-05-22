# HumaraCart Demo Plan

Working notes for recording and producing the Builders Club submission video for HumaraCart. Captures what the demo needs to show, how to record it on Linux + Android, and the post-production pipeline.

## Goal

Produce a 60-90 second video proving HumaraCart works end-to-end: three household members texting a WhatsApp bot, one shared cart maintained on the backend, and a clean handoff to Instamart for checkout.

The video is the load-bearing artefact for the Builders Club application. The written brief is supporting; the demo is decisive.

---

## What needs to be on screen

- Three distinct WhatsApp chat surfaces, labelled by household member (e.g., Priya / Rahul / Sneha).
- Messages flowing from each member to the HumaraCart bot, and bot replies appearing in each respective chat.
- The unified cart visible after a `show list` command.
- The freeze action and the notification broadcast to all members.
- A brief glimpse of the Instamart app with the cart populated when the account holder opens it.

Do not show: Twilio console, backend logs, raw API traffic, or implementation details. The demo is the user experience, not the architecture. A 10-second cut to a LangSmith trace at the end is optional polish for technical readers.

---

## Recording setup

### Recommended: scrcpy + Loom (or any simple Linux recorder)

Best fit for Linux laptop + Android phones. All free.

**Prerequisites:**
- 2-3 Android phones (your own + helpers' phones).
- USB cables, one per phone. (Wi-Fi mirroring works but USB is more reliable for recording.)
- scrcpy: `sudo apt install scrcpy` or via flatpak.
- A simple screen recorder. Pick one:
  - **Loom Chrome extension** (recommended): one-click record, captures the screen, auto-uploads, gives a shareable link. Free tier covers 90-second videos easily. Zero learning curve.
  - **Kazam** (`sudo apt install kazam`): native Linux GUI, four-button interface, saves MP4 locally. Use if you prefer a local file over a cloud upload.
  - **vokoscreenNG**: similar to Kazam, slightly more options.
  - **GNOME Screen Recorder** if you're on GNOME: `Ctrl+Alt+Shift+R` to start/stop, max 30s by default, configurable via `gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0`.
- ADB enabled and USB debugging turned on for each Android device (Settings → Developer Options → USB Debugging).

**Setup steps:**
1. Connect Android phones to the laptop via USB.
2. Verify devices are seen: `adb devices`. Each phone should appear with a serial.
3. In three separate terminals, run one per phone with a labelled window title:
   - `scrcpy --serial=<device_id_1> --window-title="Priya"`
   - `scrcpy --serial=<device_id_2> --window-title="Rahul"`
   - `scrcpy --serial=<device_id_3> --window-title="Sneha"`
   Each opens an independent mirror window with the helper's name baked into the title bar. **No post-production overlay needed.**
4. Arrange the three scrcpy windows side-by-side on the desktop.
5. Each helper opens WhatsApp on their phone, texts `join <code>` to the Twilio Sandbox number once to opt in.
6. Start your screen recorder (Loom: click the extension; Kazam: open and hit record). Capture the desktop region containing the three phone mirrors.
7. Run a take.

**Why not OBS:** OBS is excellent for livestreaming and multi-source compositing, but neither is needed for a single-screen 60-90 second recording. Loom or Kazam handles this case with zero learning curve. Reach for OBS only if you later want webcam overlay or multi-scene switching.

### Alternative A: WhatsApp Web in three Chrome profiles

Three local Chrome profiles, each linked to a different WhatsApp account via QR scan. No Google sign-in required for the profiles. Desktop-styled chat UI rather than mobile.

Use this if scrcpy is fiddly or helpers cannot bring their phones for the setup step. Each helper still needs their phone online during recording so the WhatsApp Web session stays connected.

### Alternative B: Three physical phones, overhead camera

Phones flat on a desk, webcam or phone camera overhead. Most viscerally authentic, lowest production polish.

Use as fallback if mirroring fails.

---

## Accounts and helpers needed

- Your own phone number (1 account).
- A second number you control (eSIM / secondary SIM) OR a friend's phone (1 account).
- A third helper (family or another friend) (1 account).

Each helper's commitment:
- Opt into Twilio Sandbox once via `join <code>`.
- Bring their phone with USB debugging enabled (for scrcpy) or be ready to scan a QR (for WhatsApp Web).
- 10 minutes of presence during the recording.

---

## Sample recording script (~60-90 seconds)

Approximate pacing: 5-7 seconds per beat.

1. **All three windows visible.** Title card overlay: *"HumaraCart: shared household cart on WhatsApp"*.
2. **Priya:** `add milk` → bot replies in Priya's chat.
3. **Rahul:** `add detergent` → bot replies in Rahul's chat.
4. **Sneha:** `add chips` → bot replies in Sneha's chat.
5. **Rahul:** `remove detergent` → bot replies with updated list.
6. **Sneha:** `show list` → bot replies with unified cart (Milk, Chips).
7. **Priya:** `ready to order` → bot nudges the account holder.
8. **Priya (account holder):** `freeze cart` → all three chats receive the frozen notification.
9. **Cut to Instamart app** with the cart populated by the agent.
10. **Outro card:** *"Built on Swiggy Instamart MCP"* + contact link.

60 seconds reads as crisp; 90 seconds is the upper limit before pacing drags. Cut anything that doesn't earn its place.

---

## Post-production pipeline

### Editor (only needed for polish)

If you used Loom for capture, the auto-generated share link is usable as-is; no editing required. Use an editor only if you want voiceover, captions, trimming, or other polish.

**Kdenlive** is the recommended editor when you do want to edit. Open-source, Linux-native, learn in an hour. Handles:
- Trimming raw footage.
- Basic transitions and cuts.
- Audio track for narration.
- SRT subtitle import.

Window labels (Priya / Rahul / Sneha) are no longer an editor concern: `scrcpy --window-title` bakes them into the recording at capture time.

**DaVinci Resolve** (free, also Linux-native) is more powerful but heavier. Use it if you want professional motion graphics or colour grading later. Overkill for a 90-second demo.

### Captions (when there is narration)

Use Whisper to auto-transcribe:

```bash
pip install openai-whisper
whisper narration.mp3 --output_format srt
```

Drop the resulting SRT into Kdenlive's subtitle track. Polish wording manually.

Web alternatives (no install): Veed.io, CapCut Web. Both have free tiers sufficient for one 90-second video.

### Voiceover (optional but high-leverage)

Two paths:

1. **Record your own voice.** Laptop mic is fine if the room is quiet. Audacity (free) cleans noise.
2. **AI-generated via ElevenLabs.** Paste script into the web app, pick a voice, download MP3, drop into Kdenlive. Free tier covers 90 seconds.

A clean voiceover dramatically lifts perceived production quality. Worth 20 minutes even on the minimum-viable pipeline.

---

## Where AI helps and where it does not

**AI genuinely helps:**
- Auto-captioning narration (Whisper, Veed.io, CapCut).
- Voiceover generation (ElevenLabs).
- Script drafting (any LLM; can produce a 90-second narration matched to the beats above).
- Silence and filler-word removal (Descript, CapCut auto-cuts).
- One-off intro/outro title card graphics (DALL-E, Midjourney).

**AI does not help meaningfully:**
- Basic transitions, timing, layout.
- Region capture and arrangement.
- Window labels: handled by `scrcpy --window-title` at recording time, not in post.

The honest rule: AI is useful for content generation (text, audio, captions) and content cleanup (silence removal, transcription). It is not useful for layout, anchoring, or simple text overlays.

---

## Minimum-viable pipeline (fastest path to a shippable video)

1. Start `scrcpy --window-title="Priya"` (and similarly for the other two helpers); arrange the three windows side by side.
2. Click record in Loom Chrome extension (or open Kazam and hit record).
3. Run through the script; click stop.
4. Loom auto-uploads and gives you a shareable link. (Kazam saves an MP4 locally; upload it wherever.)
5. (Optional, for polish) Generate voiceover via ElevenLabs from a script, run Whisper for captions, light edit in Kdenlive, re-export.

End-to-end without polish: ~30 minutes, assuming the bot is already working.
End-to-end with voiceover + captions: ~half day.

---

## Prerequisites checklist before the recording day

- [ ] HumaraCart bot handles every command in the script without manual intervention.
- [ ] Twilio Sandbox configured; bot number live; three helpers opted in via `join <code>`.
- [ ] scrcpy verified working with at least two Android phones connected simultaneously, each launched with a labelled `--window-title`.
- [ ] Screen recorder picked and tested (Loom Chrome extension or Kazam).
- [ ] Narration script finalised, if you want a voiceover (drafting help available when ready).
- [ ] Helpers scheduled for the 10-minute recording window.
- [ ] Backup plan picked (Alternative A or B) in case scrcpy fails on the day.
