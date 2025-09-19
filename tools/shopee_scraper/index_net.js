const { chromium } = require('playwright');

async function scrapeNetwork(url) {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ userAgent: 'Mozilla/5.0' });
  const page = await context.newPage();

  const imgs = new Set();
  page.on('response', async (response) => {
    try {
      const ct = response.headers()['content-type'] || '';
      if (ct.startsWith('image/') || /\.(png|jpg|jpeg|webp|gif)(\?|$)/i.test(response.url())) {
        imgs.add(response.url());
      }
    } catch (e) {}
  });

  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    // wait a bit more for lazy loads
    await page.waitForTimeout(3000);
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
  if (!url) { console.error('Usage: node index_net.js <url>'); process.exit(1); }
  scrapeNetwork(url);
}
