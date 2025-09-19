Playwright Shopee Scraper

This small tool renders a Shopee product page with Playwright and extracts image URLs (og:image, img tags, background images, JSON-LD).

Requirements
- Node.js (16+ recommended)

Install

```bash
cd tools/shopee_scraper
npm install
```

Run

```bash
node index.js "https://shopee.ph/your-product-url"
```

The script will print a JSON object with the page URL and an array of found image URLs.

Notes
- Playwright may download browser binaries on first run (npm install or playwright install).
- If you want to run without downloading browsers, use Playwright's driverless options or install the browsers via `npx playwright install`.
