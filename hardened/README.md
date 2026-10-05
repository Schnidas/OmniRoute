# Hardened local setup (fork-only addition)

This folder is not part of upstream OmniRoute. It is a small, reviewed way to
run it locally for experiments. Upstream: github.com/diegosouzapw/OmniRoute,
pinned to the reviewed commit `23a11484862b3bb589a55e85b00e4ac53ffeb234`
(v3.8.52). `setup.sh` refuses to run on any other commit unless you set
`ALLOW_UNREVIEWED=1` after reading the diff.

## What it changes from upstream defaults
| Setting | Upstream default | Here |
|---|---|---|
| `OMNIROUTE_SERVER_HOST` | `0.0.0.0` (whole network) | `127.0.0.1` |
| `REQUIRE_API_KEY` | `false` | `true` |
| Conversation tracking | on | off |
| Request body logs | off | off |
| PII and credential redaction | off | on |
| Secrets and dashboard password | placeholders | random, generated on your machine |

## Use
1. `./hardened/setup.sh` writes `~/.omniroute-hardened/.env` (mode 600). Nothing is
   started and nothing secret is ever stored in this repo.
2. `npm ci && npm run build`, then `DATA_DIR=~/.omniroute-hardened node bin/omniroute.mjs`.
3. Open `http://127.0.0.1:20128`, add free providers, create an API key.
4. `OMNIROUTE_KEY=<that key> ./hardened/run-claude.sh` starts Claude Code through it
   for that one command only. Normal sessions are untouched.
5. When done: stop the server and delete `~/.omniroute-hardened`.

## Rules for use
- Throwaway projects only. Free providers can see (and some train on) your prompts.
- Never add your Claude login or any account you care about.
- Do not enable: Radar, cloud sync, the free-proxy pool, MITM/AgentBridge, the
  docker compose `cli` profile (mounts docker.sock), or any auto-update.
- Do not use `-web` providers, `tos: avoid` rows, or `auto/*` combos for real code.

## Status
These scripts were written after a read-only review and are only partly tested:
the env generation and the pin check were run; building and starting the server
were not. Read them before running.
