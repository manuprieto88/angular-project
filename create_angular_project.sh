#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Script: crear-proyecto-examen-angular.sh
# Uso:
#   ./crear-proyecto-examen-angular.sh nombre-proyecto
# Si no pasas nombre, usa "examen-angular"
# ==============================

PROJECT_NAME="${1:-examen-angular}"

echo "👉 Creando proyecto Angular: ${PROJECT_NAME}"

# 1. Crear proyecto (standalone, con routing, sin tests)
ng new "$PROJECT_NAME" \
  --standalone \
  --routing \
  --skip-tests \
  --style=css

cd "$PROJECT_NAME"

echo "👉 Instalando Bootstrap 5.3.8"
npm install bootstrap@5.3.8

echo "👉 Añadiendo Bootstrap a angular.json"
node <<'NODE'
const fs = require('fs');
const path = 'angular.json';

const json = JSON.parse(fs.readFileSync(path, 'utf8'));
const projectName = json.defaultProject || Object.keys(json.projects)[0];
const buildOptions = json.projects[projectName].architect.build.options;

const bootstrapPath = "node_modules/bootstrap/dist/css/bootstrap.min.css";

buildOptions.styles = buildOptions.styles || [];
if (!buildOptions.styles.includes(bootstrapPath)) {
  // Lo ponemos el primero, como en la plantilla
  buildOptions.styles.unshift(bootstrapPath);
  console.log("✔ Bootstrap añadido a styles");
} else {
  console.log("ℹ Bootstrap ya estaba en styles");
}

fs.writeFileSync(path, JSON.stringify(json, null, 2));
NODE

echo "👉 Sobrescribiendo src/app/app.config.ts con configuración de examen"
cat > src/app/app.config.ts <<'EOF'
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient() // ← HttpClient para la API
  ]
};
EOF

echo "👉 Generando estructura de componentes (header, footer, lista, detalle, busquedas)"
ng g c components/header --skip-tests
ng g c components/footer --skip-tests
ng g c components/lista --skip-tests
ng g c components/detalle --skip-tests
ng g c components/busqueda1 --skip-tests
ng g c components/busqueda2 --skip-tests

echo "👉 Generando servicio de datos"
ng g s services/datos --skip-tests

echo "👉 Creando carpeta de interfaces vacía"
mkdir -p src/app/interfaces
touch src/app/interfaces/datos.interface.ts

echo "✅ Proyecto base creado."
echo
echo "Siguientes pasos recomendados:"
echo "  1) Define las interfaces en src/app/interfaces/datos.interface.ts"
echo "  2) Implementa el servicio en src/app/services/datos.service.ts"
echo "  3) Configura rutas en src/app/app.routes.ts (lista, lista/:id, busqueda1, busqueda2)"
echo "  4) Rellena header/footer/lista/detalle/busquedas con la plantilla del examen"
echo "  5) Añade mecanismos de accesibilidad (alt, aria-label, roles, etc.)"
echo
echo "Para arrancar:"
echo "  cd ${PROJECT_NAME}"
echo "  ng serve --open"
