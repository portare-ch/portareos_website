# os.portare.org

The website for [PortareOS](https://github.com/portare-ch/distribution) — a personal fork of
ROCKNIX for the Retroid Pocket Nova.

One hand-written `index.html`. No build step, no dependencies, no JavaScript. The only
external request is a Google Fonts stylesheet for VT323, used for the wordmark; everything
else falls back to system typefaces.

Deliberately styled after a late-90s project page: fixed 640px column, bevelled panel,
blue-and-purple links, horizontal rules, bordered tables. Two of the period tropes are
literally true here — the page really is under construction, and the target hardware really
is a 1280×960 4:3 display.

## Deploying

Serve `index.html` at the domain root. That is the whole procedure.

## Editing

Content and styles live in the one file. Keep it that way unless there is a real reason not
to; the point of the thing is that it is small.
