const fs = require('fs');
const path = require('path');

const rootDir = process.argv[2] ? path.resolve(process.argv[2]) : path.resolve('examen-angular');
let missingCount = 0;

function hasA11yAttribute(tagName, element) {
  const hasAriaLabel = /aria-label\s*=\s*["']/i.test(element);
  if (tagName === 'img') {
    const hasAlt = /\salt\s*=\s*["']/i.test(element);
    return hasAlt || hasAriaLabel;
  }
  return hasAriaLabel;
}

function logMissing(filePath, element) {
  missingCount += 1;
  console.log(`⚠ Falta aria-label/alt → ${filePath} → ${element}`);
}

function scan(dir) {
  fs.readdirSync(dir).forEach((file) => {
    const full = path.join(dir, file);
    const stat = fs.statSync(full);

    if (stat.isDirectory()) {
      scan(full);
      return;
    }

    if (!full.endsWith('.html') && !full.endsWith('.component.html')) return;

    const content = fs.readFileSync(full, 'utf8');
    const elements = content.match(/<(button|a|input|img)[^>]*>/gi) || [];

    elements.forEach((element) => {
      const tagName = (element.match(/^<(\w+)/i) || [])[1];
      if (!tagName) return;
      if (!hasA11yAttribute(tagName.toLowerCase(), element)) {
        logMissing(full, element.trim());
      }
    });
  });
}

if (!fs.existsSync(rootDir)) {
  console.error(`No existe el directorio ${rootDir}`);
  process.exit(1);
}

scan(rootDir);

if (missingCount === 0) {
  console.log('✅ Todos los botones, enlaces, inputs e imágenes tienen aria-label o alt.');
} else {
  console.log(`Se encontraron ${missingCount} elementos sin aria-label/alt.`);
}
