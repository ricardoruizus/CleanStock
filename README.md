# 📦 CleanStock - Sistema de Gestión de Inventario y Ventas

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![VS Code](https://img.shields.io/badge/VS%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/)

**CleanStock** es una aplicación integral diseñada para la gestión eficiente de inventarios, control de ventas y administración de proveedores. 

Construida con Flutter, la aplicación está **optimizada exclusivamente para tablets**, ofreciendo una experiencia de usuario fluida, con una interfaz minimalista, limpia y fácil de navegar que aprovecha al máximo el espacio en pantalla.

---

## ✨ Características Principales

* **Dashboard Intuitivo:** Acceso rápido a los módulos principales (Inventario, Ventas, Proveedores y Registro) con indicadores visuales de alertas.
* **Gestión de Inventario:** Control detallado de productos con filtros por estado (Activos, Bajo stock, Agotados).
* **Punto de Venta (POS) Integrado:** Registro de ventas fluido con un panel interactivo, teclado numérico en pantalla y cálculo automático de totales.
* **Centro de Alertas Inteligente:** Monitoreo en tiempo real de existencias críticas, productos agotados y sugerencias de acciones (ej. generar órdenes de compra).
* **Directorio de Proveedores:** Organización de contactos por categorías (Limpieza, Comida, etc.) para un reabastecimiento rápido.
* **Diseño Minimalista:** Interfaz cuidada con paletas de colores suaves y tipografía clara, inspirada en los estándares de Cupertino y Material Design para reducir la fatiga visual del usuario.
* **Modo Claro / Oscuro:** Soporte nativo para cambio de tema desde la configuración.

---

## 📸 Vistas de la Aplicación

*(Nota: Sube las capturas a tu repositorio en una carpeta `assets/screenshots/` y actualiza estos enlaces)*

| Inicio de Sesión | Dashboard Principal |
| :---: | :---: |
| ![Login](ruta/a/login.png) | ![Dashboard](ruta/a/dashboard.png) |

| Control de Inventario | Registro de Ventas (POS) |
| :---: | :---: |
| ![Inventario](ruta/a/inventario.png) | ![Ventas](ruta/a/ventas.png) |

| Centro de Alertas | Gestión de Proveedores |
| :---: | :---: |
| ![Alertas](ruta/a/alertas.png) | ![Proveedores](ruta/a/proveedores.png) |

---

## 🔥 Integración con Firebase (Roadmap)

Actualmente nos encontramos trabajando en el backend de la aplicación. El objetivo es configurar el proyecto de Firebase, activar la base de datos Cloud Firestore y definir la estructura inicial de las colecciones para el gestor de ventas, inventario y pedidos, asegurando la optimización de lectura/escritura bajo el plan gratuito (Spark).

**Tareas pendientes:**

- [ ] Diseño de Base de Datos (Diagrama físico)
- [ ] Crear el proyecto en FireBase y vinculación a la aplicación móvil.
- [ ] Habilitar **Firebase Authentication**.
- [ ] Configurar el SDK de Firebase en el entorno de desarrollo de la app móvil.

---

## 🛠️ Requisitos Previos

Asegúrate de tener instalado lo siguiente en tu entorno de desarrollo:

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versión más reciente recomendada).
* [Visual Studio Code](https://code.visualstudio.com/).
* Extensiones de VS Code: `Flutter` y `Dart`.
* Emulador de Tablet configurado (ej. iPad Simulator o Android Tablet AVD).

---

## 🚀 Configuración y Ejecución (VS Code)

1. **Clona este repositorio:**
   ```bash
   git clone https://github.com/ricardoruizus/CleanStock.git
