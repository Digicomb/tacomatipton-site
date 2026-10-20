# tacomatipton.com

Astro site for Tacoma Tipton (single-family rental homes in Akron, OH and New Albany, IN), built on the same structure as missional.io, digitalhoneycomb.com, dreamdrivenmoney.com and myhostadvantage.com.

| Command           | Action                                  |
| :---------------- | :-------------------------------------- |
| `npm install`     | Install dependencies                    |
| `npm run dev`     | Dev server at `localhost:4321`          |
| `npm run build`   | Build to `./dist/`                      |
| `npm run preview` | Preview the production build locally    |

- Content: `src/pages/index.astro` (locations, reasons, steps, resident links and FAQs are arrays at the top).
- Form choices: `src/options.ts` (topics and locations). If you rename or add one, update the `tt_contact_topic_valid` / `tt_contact_location_valid` checks in the database too.
- Hero art: `src/components/Street.astro`.
- Icons: edit `public/favicon.svg` (keep `src/assets/logo.svg` in sync), then run `node scripts/make-icons.cjs`.
- Analytics: set `gaId` in `src/layouts/Base.astro` to turn on GA4 (and add it to the privacy policy).
- Deploy: `.github/workflows/deploy.yml` publishes to GitHub Pages on push to `main`.

## Contact form

The form inserts into `tt_contact_requests` in the shared Digicomb Supabase project (also used by missional.io, which owns the keep-alive job). The public key can insert but not read. A database trigger emails each request through Resend from notifications@digicomb.com (the shared Resend domain), with the visitor as reply-to.

Setup: run `supabase/migrations/001_tt_contact_requests.sql` in the Supabase SQL Editor, then create the two Vault secrets listed in it.
