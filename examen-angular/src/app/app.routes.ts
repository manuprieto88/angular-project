import { Busqueda1Component } from './components/busqueda1/busqueda1.ts';
import { Busqueda2Component } from './components/busqueda2/busqueda2.ts';
import { DetalleComponent } from './components/detalle/detalle.ts';
import { ListaComponent } from './components/lista/lista.ts';
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: 'lista', component: ListaComponent },
  { path: 'lista/:id', component: DetalleComponent },
  { path: 'busqueda1', component: Busqueda1Component },
  { path: 'busqueda2', component: Busqueda2Component }
];
