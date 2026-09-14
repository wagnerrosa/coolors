# Coolors

A gallery of three-colour palettes with click-to-copy hex values and heart voting.

Originally built in Lisbon, April–May 2016, while I was learning Rails — 49 commits between
26 April and 14 May. It ran on Heroku at `coolors.wagnerrosa.com` until the dyno was removed.
This is the same app, revived on a current stack, with the 2016 design kept intact.

## Why it was rewritten rather than redeployed

The original Gemfile pinned Ruby 2.2.3, which no current PaaS offers. That forces Ruby 3.1+,
and Rails 4.2.5 cannot run on Ruby 3 (keyword-argument separation, `Fixnum`/`Bignum` removal).
Rails 4.2 → 8.1 is six major versions, while the app's actual logic is about 125 lines of Ruby —
so the logic was ported onto a fresh Rails 8 app instead.

Deliberately preserved: the ~570 lines of hand-written Sass (including the colour-cycling
keyframe animations on the header and logo), the inline Lisbon tram SVG in the footer, the
Ionicons and Google Fonts choices, and all of the original copy.

Dropped: Bootstrap 4.0.0-alpha.2 (replaced by CSS Grid), clipboard.js (replaced by
`navigator.clipboard`), Universal Analytics (dead since 2023), and the `thumbs_up` gem
(replaced by a hand-rolled `Vote` model, so that voting works without an account).

## Stack

- Ruby 3.4.3, Rails 8.1
- PostgreSQL (Neon)
- Propshaft + `dartsass-rails` — Dart Sass reads the original indented `.sass` files unconverted
- importmap + Stimulus, no Node build step
- Devise 5 for the single admin account

## Local development

```bash
bundle install
bin/rails db:prepare      # needs DATABASE_URL, or a local PostgreSQL
bin/rails db:seed         # creates the admin from ENV, plus sample palettes
bin/dev                   # Rails + Dart Sass watcher
```

Environment variables:

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string (Neon: use the **direct**, non-pooler endpoint, with `?sslmode=require`) |
| `RAILS_MASTER_KEY` | Contents of `config/master.key` |
| `ADMIN_EMAIL` | Seeded admin account |
| `ADMIN_PASSWORD` | Seeded admin password |

Sign-ups are disabled by design — there is one admin account, seeded from those variables.

## Deployment

Render free web service (`render.yaml` is checked in) plus Neon free Postgres.

Migrations and seeds run from `bin/render-build.sh`, because Render's `preDeployCommand` is
paid-only and the free plan has no shell access.

Note: the free instance spins down after 15 minutes idle, so the first request after a quiet
period takes roughly 60 seconds.

## Behaviour notes

Voting is anonymous — one vote per visitor per palette, enforced by a unique index on
`[color_id, voter_key]`, where `voter_key` is a signed cookie (or the user id when signed in).

Three bugs from 2016 were fixed in the port, listed in `CLAUDE.md` so they are not mistaken
for regressions later.

---

Built with ♥ in Lisbon.
