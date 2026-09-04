# os.portare.org

The website for [PortareOS](https://github.com/portare-ch/distribution) — a personal fork of
ROCKNIX for the Retroid Pocket Nova.

One hand-written `index.html`. No build step, no framework, **no JavaScript**. The only
external request the page makes is a Google Fonts stylesheet for VT323, used for the
wordmark; everything else falls back to system typefaces.

Deliberately styled after a late-90s project page: fixed 640px column, bevelled panel,
blue-and-purple links, horizontal rules, bordered tables. Two of the period tropes are
literally true here — the page really is under construction, and the target hardware really
is a 1280×960 4:3 display.

## Hosting

GitHub Pages, published by `.github/workflows/deploy.yml` on every push to `main`, once a
day on a schedule, and on demand.

It deploys with the Pages Actions rather than the "deploy from a branch" setting, for a
specific reason: a push made with `GITHUB_TOKEN` does not create workflow runs, so a job that
commits the counter and expects a branch deploy to notice would silently never republish.
Baking and deploying in one run avoids the problem, and keeps daily `counter: 0000123`
commits out of the history.

Because the deploy is a custom workflow, GitHub does **not** create the `CNAME` file for us —
it is committed here, containing `os.portare.org`. Do not delete it.

Only `index.html` and `CNAME` are published; the README and `tools/` stay in the repository.

## The visitor counter

It is fake, and it involves no JavaScript.

There is no pixel, no analytics and no third party. A real count needs at least one of
those, and the badge next to it says NO JS. `tools/bake-counter.sh` computes a number from
the date at deploy time and writes it between the `<!--HITS-->` markers, so what the visitor
loads is a plain static string.

It is deterministic: the same day always produces the same number, so a re-deploy never makes
it jump or go backwards. The daily drift is larger than the jitter, which keeps it climbing.
The daily schedule in the deploy workflow is what moves it.

This is decoration, in the same spirit as "best viewed at 1280x960". If you ever want real
numbers, they need a real counter, and this script is not it.

## Editing

Content and styles live in the one file. Keep it that way unless there is a real reason not
to; the point of the thing is that it is small.
