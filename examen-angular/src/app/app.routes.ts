import { Busqueda1Component } from './components/busqueda1/busqueda1';
import { Busqueda2Component } from './components/busqueda2/busqueda2';
import { DetalleComponent } from './components/detalle/detalle';
import { ListaComponent } from './components/lista/lista';
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: 'lista', component: ListaComponent },
  { path: 'lista/:id', component: DetalleComponent },
  { path: 'busqueda1', component: Busqueda1Component },
  { path: 'busqueda2', component: Busqueda2Component }
];
