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

It is real, and it still involves no JavaScript. The two halves are separate:

**Counting** is an image request, exactly as it was in 1997 — a 1×1 GIF from
[GoatCounter](https://www.goatcounter.com), in a commented-out `<img>` at the bottom of
`index.html`.

**Displaying** happens at deploy time. `tools/bake-counter.sh` reads the running total back
out of GoatCounter's API and writes it between the `<!--HITS-->` markers, so what the
visitor loads is a plain static string.

The number therefore lags by up to a day. That is not a defect — it is how a counter behaved
when the webmaster regenerated the page by hand.

### Turning it on

1. Create a site at goatcounter.com and note your code (the `MYCODE` in
   `MYCODE.goatcounter.com`).
2. Uncomment the `<img>` at the bottom of `index.html` and replace `MYCODE`.
3. In GoatCounter, create an API token with the *read statistics* scope.
4. In this repository: set a variable `GOATCOUNTER_CODE` to your code, and a secret
   `GOATCOUNTER_TOKEN` to the token.

Until then the deploy still works, the bake step skips without failing, and the counter reads
`0000000`. If the API call fails on a later run the script leaves the page untouched rather
than baking in a broken number.

## Editing

Content and styles live in the one file. Keep it that way unless there is a real reason not
to; the point of the thing is that it is small.
