const { chromium } = require('playwright');

async function scrape(url) {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ userAgent: 'Mozilla/5.0' });
  const page = await context.newPage();
  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });

    // Wait a bit for client-rendered images to appear
    await page.waitForTimeout(2000);

    // Try common selectors for product images
    const srcs = await page.evaluate(() => {
      const urls = new Set();
      // og:image meta
      const og = document.querySelector("meta[property='og:image']");
      if (og && og.content) urls.add(og.content);

      // img tags
      document.querySelectorAll('img').forEach(img => {
        if (img.src) urls.add(img.src);
        if (img.getAttribute('data-src')) urls.add(img.getAttribute('data-src'));
      });

      // background images
      document.querySelectorAll('*').forEach(el => {
        const bg = window.getComputedStyle(el).backgroundImage || '';
        const m = bg.match(/url\(["']?(.*?)["']?\)/);
        if (m && m[1]) urls.add(m[1]);
      });

      // search for JSON embedded images in scripts
      document.querySelectorAll('script[type="application/ld+json"]').forEach(s => {
        try {
          const j = JSON.parse(s.textContent || '{}');
          if (j && j.image) {
            if (Array.isArray(j.image)) j.image.forEach(i => urls.add(i));
            else urls.add(j.image);
          }
        } catch (e) {}
      });

      return Array.from(urls).filter(u => !!u);
    });

    console.log(JSON.stringify({ url, images: srcs }, null, 2));
  } catch (e) {
    console.error('ERROR', e && e.message ? e.message : e);
    process.exitCode = 2;
  } finally {
    await browser.close();
  }
}

if (require.main === module) {
  const url = process.argv[2];
  if (!url) {
    console.error('Usage: node index.js <url>');
    process.exit(1);
  }
  scrape(url);
}
