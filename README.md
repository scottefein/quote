# The (Obscure) Quote of the Moment Service

This is a long-lived branch of the [quote service](https://github.com/datawire/quote) for use in the tour application.

This branch is pulled into [datawire/tour](https://github.com/datawire/tour) as the `backend/` directory via a `git subtree`.

All updates to the tour backend should be made against the [tour-master](https://github.com/datawire/quote/tree/tour-master) branch of [datawire/quote](https://github.com/datawire/quote) and pulled into tour by running:

```
git subtree pull --prefix backend https://github.com/datawire/quote tour-master --squash
```
