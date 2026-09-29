# CLAUDE.md — Coolors

Project memory. Read this before changing anything that looks like a mistake; some of it is
deliberate.

## Origin

Built in Lisbon while Wagner was learning Rails: 49 commits, 2016-04-26 → 2016-05-14.
Peak of 12 commits on 11 May — the voting day ("Vote system with thumbs_up gem working",
"Bug at redirect_back", "Button votes working"). The first 6 commits are `+0100` and the
remaining 43 are `+0200`, which is Portugal's DST shift on 2016-05-01.

The git history from 2016 is preserved in this repository; the Rails 8 port sits on top of it.

The 2016 app is reachable by name as well as by hash: branch `rails-4-2016` and tag
`v2016-final` both point at `6f0d8d8`, the last commit before the port — Rails 4.2.5 on
Ruby 2.2.3, with the vendored Bootstrap alpha still in place. Nothing depends on them; they
exist so that state can be checked out without hunting for a hash.

## Why the rewrite

The 2016 Gemfile pinned Ruby 2.2.3. No current PaaS offers it (Heroku's oldest runtime is 3.1.0,
already deprecated), and Rails 4.2.5 cannot run on Ruby 3. Rails 4.2 → 8.1 is six majors against
~125 lines of actual application logic, so the logic was ported onto a fresh Rails 8 scaffold
rather than upgraded five times in sequence.

## Deliberately preserved

- The six hand-written Sass files (`_vars`, `_header`, `_colors`, `_colors-drop`, `_forms`,
  `_footer`) — including the `header-animation` / `logo-animation` colour-cycling keyframes and
  the responsive breakpoints down to 300px. They are the point of the exercise.
- The inline Lisbon tram SVG in `app/views/layouts/_footer.html.erb` (the `#bondinho` rect is
  what turns green on hover).
- Ionicons 2.0.1 and Google Fonts Catamaran + Monoton.
- All original copy, including "Built with ♥ in Lisbon" and `© 2016, Coolors.`

Dart Sass reads the indented `.sass` syntax natively, so those files compile unconverted. They
were renamed to `_partial.sass` and each got a `@use "vars" as *` header, because Dart Sass
`@use` is namespaced where the 2016 `@import` was global. The Google Fonts `@import url(...)`
lines moved from `_vars.sass` into the layout as `<link>` tags.

## Deliberately dropped

- `bootstrap.css.scss` — 95KB of Bootstrap 4.0.0-alpha.2. The grid is now ~20 lines of CSS Grid
  at the end of `_colors.sass`.
- `clipboard.js` → `navigator.clipboard` in `app/javascript/controllers/clipboard_controller.js`.
  The 2016 init was duplicated verbatim in three views and leaked listeners on navigation.
- `google_analytics.js.coffee` — classic `_gaq`/ga.js, property `UA-50334321-4`. Universal
  Analytics stopped processing data in 2023.
- `thumbs_up` gem and its copied-in polymorphic `Vote` model.
- The `upvotes` table — it was in `schema.rb` with no migration creating it, and no model. Orphan.
- 10 of the 11 Devise views. `:registerable` and `:recoverable` are off, so they were unreachable,
  and six of them called `devise_error_messages!`, removed in Devise 4.2+. Only
  `sessions/new.html.erb` was kept.

## Registration stays disabled

`User` declares only `:database_authenticatable, :rememberable, :trackable, :validatable`.
This is intentional, from 2016 ("Users cant edit profile"; the README said "just me to manage
the trolls"). The single admin is seeded from `ADMIN_EMAIL` / `ADMIN_PASSWORD`.

## The three 2016 bugs, fixed in the port

Do not mistake these for regressions — they were broken in the original.

1. **`vote_up` crashed for logged-out visitors.** The action was in the `authenticate_user!`
   `except:` list but called `current_user.vote_for(@color)`, so it raised `NoMethodError` on
   nil. Public voting never actually worked in production, despite the commit "Current user
   first always to enable public vote".
2. **Alerts never rendered.** The layout read `<% if notice %> … <% elsif notice %>`, re-testing
   `notice`, so the `alert` branch was unreachable. Now `<% elsif alert %>`.
3. **`_form.html.erb` printed a raw array.** It used `<%= @color.errors.full_messages.each do |msg| %>`
   — an output tag on an `each` — which rendered the array after the list. Now `<% … %>`.

## Voting design

`acts_as_votable` was rejected: it refuses nil voters (`votable.rb:67`), and voting here is
anonymous. The hand-rolled `Vote` model uses `voter_key` — a signed cookie UUID for anonymous
visitors, or `"user:#{id}"` when signed in — with a unique index on `[color_id, voter_key]`.

This replaces the 2016 rate-limit hack, which bumped `updated_at` on the *color* and therefore
blocked *every* visitor from voting for a minute after anyone voted.

`votes_count` is a counter cache, so `/colors/trend` is `order(votes_count: :desc)` rather than
`plusminus_tally`.

## Other port changes

- `update_attributes` → `update` (removed in Rails 6.1).
- `redirect_to :back` → `redirect_back(fallback_location:)` (removed in Rails 5); the two
  `rescue ActionController::RedirectBackError` blocks became dead code and were deleted.
- `vote_up` is **POST**, not GET — it mutates state, and a GET link let crawlers vote.
- Removed the catch-all `get '*path' => redirect('/')`, which swallowed every 404 including
  broken Devise paths.
- `show.html.erb` share links used a hardcoded `http://coolors.wagnerrosa.com/colors/<id>`;
  they now use `color_url(@color)`.

## Security notes

The 2016 repo had the admin credentials in two live places — `README.md` and as `<small>` hints
under the login form — plus a committed dev/test `secret_key_base` in `config/secrets.yml`.
All were public on GitHub. The credentials are gone from both places, `secrets.yml` is replaced
by Rails 8 credentials, and the admin password must be set fresh in Render's dashboard.

Production was never exposed by this: it correctly read `ENV["SECRET_KEY_BASE"]`.

## Deployment

Render free web service + Neon free Postgres. Neon's free tier is permanent; Render's own free
Postgres is deleted 30 days after creation, which is why it is not used.

Use Neon's **direct** (non-pooler) endpoint: Render free runs a single instance with
`WEB_CONCURRENCY=2`, so PgBouncer buys nothing, and migrations need session-level advisory locks
the pooler does not support. `prepared_statements: false` is *not* needed — that advice predates
PgBouncer 1.22, and Neon's pooler supports protocol-level prepared statements.

Migrations and seeds run in `bin/render-build.sh` because `preDeployCommand` is paid-only and
the free plan has no shell access (no `rails console`).

Live since 2026-09-29 at https://coolors.wagnerrosa.com — Render service `coolors-hk2f`, reached
through a `CNAME coolors → coolors-hk2f.onrender.com.` on the `wagnerrosa.com` zone. That record
used to point at `coolorsonrails.herokuapp.com`, the 2016 Heroku app, which no longer exists; a
CNAME left dangling there is a subdomain-takeover risk. Render issues and renews the TLS
certificate. `config.hosts` is unset, so no host allowlist needs updating if the domain changes.

Neon's free plan archives an idle branch to cold storage: `production` was archived on
2026-09-28 after ~13 days without a connection, and unarchived itself on the next connect. No
data is lost, but the first request after a long idle spell pays for the unarchive on top of
Render's own free-tier cold start.

## Secrets — where they live

**Nothing secret belongs in this file.** It is versioned and public on GitHub. The 2016 repo
leaked the admin password through the README and the login form, and committed a dev/test
`secret_key_base` in `config/secrets.yml`; that is the mistake this section exists to prevent.

| Secret | Where it lives |
|---|---|
| `RAILS_MASTER_KEY` | `config/master.key`, gitignored via `/config/*.key`. Backed up outside the repo at `../coolors-backup-2016/MASTER_KEY_coolors.txt`. Without it `credentials.yml.enc` cannot be decrypted. |
| `ADMIN_PASSWORD` | Render dashboard only. Must be a **new** password — the 2016 one is in public git history forever. |
| `ADMIN_EMAIL` | Render dashboard. |
| `DATABASE_URL` | Render dashboard. Neon direct (non-pooler) endpoint, with `?sslmode=require`. |

Neon project id: `royal-bar-84649667`. The `neon` CLI is installed globally; `neon auth` needs an
interactive browser and times out after 60 seconds in a non-interactive shell.

## Port status (2026-09-14)

The Rails 8 port is commit `91eb075`, sitting on top of the 49 commits from 2016 (`6f0d8d8` is
the last 2016 commit, `75bb851` the initial one). Same repository, same `master` branch, same
remote — the history is continuous, and the Sass files registered as renames rather than
rewrites.

The pre-port 2016 working tree is preserved at `../coolors-backup-2016/`.

Verified so far: Dart Sass compiles the six 2016 stylesheets (10.4KB output, both keyframe
animations present), the app boots on Rails 8.1.3.1, all ported Ruby passes `ruby -c`, and the
routes are correct (`vote_up` is POST, `trend_colors` is GET, no catch-all).

Verified against Neon: migrations create the three tables, seeds produce the admin plus four
palettes, and `test/integration/port_verification_test.rb` covers all three 2016 bugs —
6 runs, 25 assertions, 0 failures.

Two problems the port introduced and fixed along the way:

- `json` 3.0 dropped the second argument from `JSON.parse`, which `ActiveSupport::JSON.decode`
  still passes. Every request that read an encrypted session cookie returned 500, so all POSTs
  failed, Devise's `sign_in` included. It is pinned to `~> 2.7`.
- `button_to`'s block form takes `(options, html_options)`, so `class:` became a second
  positional argument and broke rendering.

## Running the test suite

It needs a local PostgreSQL, which is deliberate: `dotenv` is development-only so that
`DATABASE_URL` cannot reach the suite, and `test_helper` aborts if the connection points at
neon.tech. Without a local server the suite fails to connect — which is the intended failure,
because the alternative is writing to the database that serves the live site.

**Done:** the app lives at `Projetos/coolors/` (the 2016 tree it replaced is backed up at
`../coolors-backup-2016/`), and `master`, `rails-4-2016` and `v2016-final` are all pushed.
The Render service is created and the site is live (see Deployment).

## Dependabot

`.github/dependabot.yml` and `.github/workflows/ci.yml` came from the Rails 8 scaffold in
`91eb075` — they were not in the 2016 repo, and GitHub opened four `dependabot/*` branches
off them. One of those, `dependabot/bundler/json-3.0.2`, proposes exactly the upgrade that
breaks every POST (see the json note above), so the config now ignores `json >= 3.0`.
Close that PR rather than merging it.
