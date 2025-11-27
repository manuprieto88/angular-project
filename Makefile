PROJECT_NAME ?= examen-angular
PROJECT_DIR := $(PROJECT_NAME)
APP_DIR := $(PROJECT_DIR)/src/app
ANGULAR_JSON := $(PROJECT_DIR)/angular.json
TEMPLATE_DIR := templates/homepage

.ONESHELL:

.PHONY: help create bootstrap homepage routes setup

help:
	@echo "Objetivos disponibles:"
	@echo "  make create PROJECT_NAME=mi-app  - Crea un proyecto nuevo usando create_angular_project.sh"
	@echo "  make bootstrap [PROJECT_NAME=...]  - Instala dependencias y añade Bootstrap al angular.json"
	@echo "  make homepage  [PROJECT_NAME=...]  - Copia la página de inicio plantilla en src/app"
	@echo "  make routes    [PROJECT_NAME=...]  - Genera/actualiza src/app/app.routes.ts con las rutas básicas"
	@echo "  make setup     [PROJECT_NAME=...]  - Ejecuta bootstrap + homepage sobre el proyecto"

create:
	./create_angular_project.sh $(PROJECT_NAME)

bootstrap:
	cd $(PROJECT_DIR) && npm install
	cd $(PROJECT_DIR) && npm install bootstrap@5.3.8
	cd $(PROJECT_DIR) && node -e "const fs=require('fs');const path='angular.json';const json=JSON.parse(fs.readFileSync(path,'utf8'));const project=json.defaultProject||Object.keys(json.projects)[0];const build=json.projects[project].architect.build.options;const css='node_modules/bootstrap/dist/css/bootstrap.min.css';build.styles=build.styles||[];if(!build.styles.includes(css)){build.styles.unshift(css);fs.writeFileSync(path, JSON.stringify(json,null,2));console.log('Bootstrap añadido a angular.json');}else{console.log('Bootstrap ya estaba configurado');}"

homepage:
	cp $(TEMPLATE_DIR)/app.html $(APP_DIR)/app.html
	cp $(TEMPLATE_DIR)/app.css $(APP_DIR)/app.css
	cp $(TEMPLATE_DIR)/app.ts $(APP_DIR)/app.ts

routes:
	@node - <<'NODE'
	const fs = require('fs');
	const path = require('path');
	const appDir = '$(APP_DIR)';
	const routesPath = path.join(appDir, 'app.routes.ts');
	const componentsDir = path.join(appDir, 'components');
	const desired = [
	  { path: 'lista', dir: 'lista', className: 'ListaComponent' },
	  { path: 'lista/:id', dir: 'detalle', className: 'DetalleComponent' },
	  { path: 'busqueda1', dir: 'busqueda1', className: 'Busqueda1Component' },
	  { path: 'busqueda2', dir: 'busqueda2', className: 'Busqueda2Component' },
	];
	
	const importLines = new Map();
	if (fs.existsSync(routesPath)) {
	  const content = fs.readFileSync(routesPath, 'utf8');
	  (content.match(/^import .*;$$/gm) || []).forEach((line) => importLines.set(line.trim(), true));
	}
	importLines.set("import { Routes } from '@angular/router';", true);
	
	const existingRoutesText = (() => {
	  if (!fs.existsSync(routesPath)) return '';
	  const content = fs.readFileSync(routesPath, 'utf8');
	  const match = content.match(/export const routes: Routes\s*=\s*\[(.*?)\];/s);
	  return match ? match[1].trim() : '';
	})();
	
	const existingPaths = new Set();
	(existingRoutesText.match(/path:\s*['"]([^'"]+)/g) || []).forEach((entry) => {
	  const pathMatch = entry.match(/path:\s*['"]([^'"]+)/);
	  if (pathMatch) existingPaths.add(pathMatch[1]);
	});
	
	const newEntries = [];
	desired.forEach(({ path: routePath, dir, className }) => {
	          const file = path.join(componentsDir, dir, dir + '.ts');
	          if (fs.existsSync(file)) {
	            const importLine = 'import { ' + className + " } from './components/" + dir + '/' + dir + ".ts';";
	            importLines.set(importLine, true);
	            if (!existingPaths.has(routePath)) {
	              newEntries.push("  { path: '" + routePath + "', component: " + className + ' }');
	            }
	          } else {
	            console.warn('Aviso: no se encontró ' + file + ', se omite la ruta ' + routePath);
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
	            const cleaned = line.replace(/,$$/, '');
	            const suffix = index < arr.length - 1 ? ',' : '';
	            return '  ' + cleaned + suffix;
	          })
	          .join('\n');
	        const finalContent =
	          finalImports + '\n\nexport const routes: Routes = [\n' + normalizedRoutes + '\n];\n';
	fs.writeFileSync(routesPath, finalContent);
	console.log('Rutas actualizadas en', routesPath);
	NODE

setup: bootstrap homepage routes
