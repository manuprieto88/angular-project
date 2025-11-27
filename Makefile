PROJECT_NAME ?= examen-angular
PROJECT_DIR := $(PROJECT_NAME)
APP_DIR := $(PROJECT_DIR)/src/app
ANGULAR_JSON := $(PROJECT_DIR)/angular.json
TEMPLATE_DIR := templates/homepage

.PHONY: help create bootstrap homepage setup

help:
	@echo "Objetivos disponibles:"
	@echo "  make create PROJECT_NAME=mi-app  - Crea un proyecto nuevo usando create_angular_project.sh"
	@echo "  make bootstrap [PROJECT_NAME=...]  - Instala dependencias y añade Bootstrap al angular.json"
	@echo "  make homepage  [PROJECT_NAME=...]  - Copia la página de inicio plantilla en src/app"
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

setup: bootstrap homepage
