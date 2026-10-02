# MySideQuest — iOS

App nativa en SwiftUI + SwiftData con el diseño pixel-art de SideQuest.

## Requisitos
- Xcode 16+ (usa *file-system synchronized groups*; no hay que añadir archivos a mano).
- iOS 17+.

## Abrir
Abre `SideQuest/SideQuest.xcodeproj` y ejecuta en un simulador de iPhone.
Para dispositivo físico, selecciona tu *Development Team* en Signing & Capabilities.

## Estructura
- `SideQuestApp.swift` — entry point + contenedor SwiftData.
- `Theme.swift` — paleta, fuentes (Press Start 2P, Fredoka), `PixelButtonStyle`, `PixelAvatar`.
- `Models.swift` — catálogo de misiones, track de skins, modelos SwiftData (`Player`, `Completion`, `Post`, `Friend`, `ChatMessage`).
- `GameStore.swift` — auth local, XP, racha, skins, posts, amigos/mensajes.
- `Views/` — Onboarding, Travel, Pase, Racha, Friends, Perfil.

## Notas
- La persistencia es 100% local (SwiftData); el catálogo de misiones y los amigos son datos semilla. Está pensado para sustituirse por el backend de SideQuest (`GameStore` concentra todos los puntos de integración).
- Las verificaciones de foto/ubicación están simuladas; `Info.plist` ya incluye los permisos de cámara y localización.
