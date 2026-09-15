"""Package the tested website and compiled Flutter app for a separate review site."""
from pathlib import Path
import shutil

root = Path(__file__).resolve().parent.parent
out = root / 'review-dist'
app = root / 'app/build/web'
if not (app / 'main.dart.js').is_file():
    raise SystemExit('Build Flutter web with --base-href /app/ first.')
if out.exists():
    shutil.rmtree(out)
out.mkdir()
for name in ('index.html', 'styles.css', 'script.js', 'preferences.js', 'translations.js'):
    shutil.copy2(root / name, out / name)
shutil.copytree(root / 'images', out / 'images')
shutil.copytree(root / 'availability', out / 'availability')
shutil.copytree(app, out / 'app')
page = out / 'index.html'
html = page.read_text()
html = html.replace('</head>', '<meta name="robots" content="noindex,nofollow">\n</head>')
start = html.index('>', html.index('<body')) + 1
banner = '''<aside style="padding:12px 20px;text-align:center;background:#073365;color:white;font:16px/1.5 sans-serif">Review version / Versión de revisión · <a href="/app/" style="color:white;text-decoration:underline">Open app demo / Abrir demo de la aplicación</a></aside>'''
page.write_text(html[:start] + banner + html[start:])
(out / 'robots.txt').write_text('User-agent: *\nDisallow: /\n')
print('Review website and Flutter app packaged in review-dist/')
