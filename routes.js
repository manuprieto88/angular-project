const fs = require('fs');
const path = require('path');

const projectDir = process.argv[2] || 'examen-angular';
const appDir = path.join(projectDir, 'src/app');
const routesPath = path.join(appDir, 'app.routes.ts');
const componentsDir = path.join(appDir, 'components');

const desired = [
  { path: 'lista', dir: 'lista', className: 'ListaComponent' },
  { path: 'lista/:id', dir: 'detalle', className: 'DetalleComponent' },
  { path: 'busqueda1', dir: 'busqueda1', className: 'Busqueda1Component' },
  { path: 'busqueda2', dir: 'busqueda2', className: 'Busqueda2Component' },
];

if (!fs.existsSync(appDir)) {
  console.error(`No se encontró ${appDir}. Ejecuta el script desde la raíz del proyecto o pasa la ruta correcta.`);
  process.exit(1);
}

const importLines = new Map();
const normalizeImport = (line) =>
  line.trim().replace(/(from '\.[^']*)\.ts';$/, "$1';");
if (fs.existsSync(routesPath)) {
  const content = fs.readFileSync(routesPath, 'utf8');
  (content.match(/^import .*;$/gm) || []).forEach((line) =>
    importLines.set(normalizeImport(line), true)
  );
}
importLines.set("import { Routes } from '@angular/router';", true);

const existingRoutesText = (() => {
  if (!fs.existsSync(routesPath)) return '';
  const content = fs.readFileSync(routesPath, 'utf8');
  const match = content.match(/export const routes: Routes\s*=\s*\[(.*?)\];/s);
  return match ? match[1].trim() : '';
})();

const existingPaths = new Set();
(existingRoutesText.match(/path:\s*['\"]([^'\"]+)/g) || []).forEach((entry) => {
  const pathMatch = entry.match(/path:\s*['\"]([^'\"]+)/);
  if (pathMatch) existingPaths.add(pathMatch[1]);
});

const newEntries = [];
desired.forEach(({ path: routePath, dir, className }) => {
  const file = path.join(componentsDir, dir, `${dir}.ts`);
  if (fs.existsSync(file)) {
    const importLine = `import { ${className} } from './components/${dir}/${dir}';`;
    importLines.set(normalizeImport(importLine), true);
    if (!existingPaths.has(routePath)) {
      newEntries.push(`  { path: '${routePath}', component: ${className} }`);
    }
  } else {
    console.warn(`Aviso: no se encontró ${file}, se omite la ruta ${routePath}`);
  }
});

let routeBody = existingRoutesText;
if (routeBody && !routeBody.trim().endsWith(',')) routeBody += ',';
const additions = newEntries.join(',\n');
routeBody = [routeBody, additions].filter(Boolean).join('\n');

const finalImports = Array.from(importLines.keys()).sort().join('\n');
const normalizedRoutes = routeBody
  .split('\n')
  .map((line) => line.trim())
  .filter(Boolean)
  .map((line, index, arr) => {
    const cleaned = line.replace(/,$/, '');
    const suffix = index < arr.length - 1 ? ',' : '';
    return `  ${cleaned}${suffix}`;
  })
  .join('\n');

const finalContent = `${finalImports}\n\nexport const routes: Routes = [\n${normalizedRoutes}\n];\n`;
fs.writeFileSync(routesPath, finalContent);
console.log('Rutas actualizadas en', routesPath);
