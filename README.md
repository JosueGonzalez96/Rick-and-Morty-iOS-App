# 🛸 Rick and Morty iOS App

Explora personajes del universo **Rick and Morty**, consulta detalles, gestiona favoritos y visualiza ubicaciones en un mapa interactivo.  

La app combina **UIKit y SwiftUI**, arquitectura **MVVM + Combine**, y persistencia local con **CoreData**.

---

## 🚀 Características principales

- 📃 **Listado de personajes**
  - Scroll infinito y paginación.
  - Filtros por nombre, especie y estado.
  - Pull-to-refresh.
  - Indicadores de carga, error y lista vacía.
  - Mostrar imagen, nombre, especie y estado de cada personaje.

- 🔍 **Detalle de personaje**
  - Imagen completa, género, especie, estado y ubicación.
  - Botón “Ver en mapa” → ubicación simulada en MapKit.
  - Marcar como favorito.

- ⭐ **Favoritos**
  - Lista de personajes favoritos.
  - Acceso protegido por Face ID / Touch ID.

- 🗺️ **Mapa de ubicaciones**
  - Pins interactivos con la ubicación de personajes.
  - Información adicional al tocar un pin.

- 🔒 **Seguridad**
  - Autenticación biométrica para acceder a favoritos.

---

## 🏗 Arquitectura y Tecnologías

- **Arquitectura:** MVVM + Combine + Swift Concurrency (async/await)  
- **Lenguaje:** Swift 6  
- **IDE:** Xcode 26.0.1  
- **Persistencia:** CoreData para personajes, favoritos y episodios vistos  
- **Mapas:** MapKit  
- **Dependencias externas (Swift Package Manager):**  
  - [Alamofire](https://github.com/Alamofire/Alamofire) – consumo de API  
  - [SDWebImage](https://github.com/SDWebImage/SDWebImage) – carga y cache de imágenes  
  - [ViewInspector](https://github.com/nalexn/ViewInspector) – pruebas unitarias SwiftUI  

---

## 📦 Instalación y ejecución

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/usuario/rickandmorty-ios-app.git
cd rickandmorty-ios-app
```
### 1️⃣ Instalar dependecias

```bash
File > Swift Packages > reset Packages caches
File > Swift Packages > Update To Lastest Packages Versions
```
### 1️⃣ Correr Test

```bash
cmnd + r
```
### 1️⃣ Correr Test

```bash
cmnd + u
