const { chromium } = require('playwright');

async function scrapeXhr(url) {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ userAgent: 'Mozilla/5.0', locale: 'en-US' });
  const page = await context.newPage();

  const imgs = new Set();
  page.on('response', async (response) => {
    try {
      const req = response.request();
      const rtype = req.resourceType();
      // capture image responses too
      const rurl = response.url();
      const ct = response.headers()['content-type'] || '';
      if (ct.startsWith('image/') || /\.(png|jpg|jpeg|webp|gif)(\?|$)/i.test(rurl)) {
        imgs.add(rurl);
        return;
      }

      // Inspect XHR/Fetch JSON/text responses for image urls
      if (rtype === 'xhr' || rtype === 'fetch' || /api|product|item|image/i.test(rurl)) {
        const text = await response.text().catch(() => '');
        if (!text) return;
        // try JSON parse
        try {
          const j = JSON.parse(text);
          // traverse object to find image-like fields
          const stack = [j];
          while (stack.length) {
            const node = stack.pop();
            if (!node) continue;
            if (typeof node === 'string') {
              if (/https?:.*\.(?:png|jpe?g|webp|gif)/i.test(node) || /https?:\/\/.+cdn/i.test(node)) imgs.add(node);
              continue;
            }
            if (Array.isArray(node)) {
              node.forEach(n => stack.push(n));
              continue;
            }
            if (typeof node === 'object') {
              for (const k of Object.keys(node)) {
                const val = node[k];
                if (typeof val === 'string') {
                  if (/https?:.*\.(?:png|jpe?g|webp|gif)/i.test(val) || /https?:\/\/.+cdn/i.test(val)) imgs.add(val);
                } else {
                  stack.push(val);
                }
              }
            }
          }
        } catch (_) {
          // fallback: regex scan for image URLs
          const found = text.match(/https?:\/\/[^"'<>\s]+?\.(?:png|jpg|jpeg|webp|gif)/ig);
          if (found) found.forEach(u => imgs.add(u));
        }
      }
    } catch (e) {}
  });

  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    // give extra time for dynamic requests
    await page.waitForTimeout(5000);
    // try clicking the first thumbnail if present (to trigger lazy load)
    try {
      const thumb = await page.$('img.shopee-image, .shopee-image, .product-image, .shop-image, .product-gallery img');
      if (thumb) await thumb.click().catch(() => {});
      await page.waitForTimeout(1000);
    } catch (e) {}

    console.log(JSON.stringify({ url, images: Array.from(imgs) }, null, 2));
  } catch (e) {
    console.error('ERROR', e && e.message ? e.message : e);
    process.exitCode = 2;
  } finally {
    await browser.close();
  }
}

if (require.main === module) {
  const url = process.argv[2];
  if (!url) { console.error('Usage: node index_net_xhr.js <url>'); process.exit(1); }
  scrapeXhr(url);
}
