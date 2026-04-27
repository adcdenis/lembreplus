# Lembre+ — Resumo do Projeto

## Visão Geral

**Lembre+** é um aplicativo Flutter para gerenciamento de lembretes, focado na plataforma Android. Permite criar, editar e organizar lembretes por categorias com persistência local via SQLite (Drift), backup/restauração em JSON e sincronização com Google Drive.

**Versão atual:** 3.0.9+1  
**Plataforma:** Android

---

## Tecnologias Principais

| Tecnologia | Propósito |
|---|---|
| Flutter + Dart | Framework e linguagem |
| flutter_riverpod | Gerenciamento de estado reativo |
| go_router | Navegação declarativa |
| drift (SQLite) | Persistência local |
| Google Drive API | Sincronização em nuvem |
| freezed + json_serializable | Modelos imutáveis e serialização |
| file_picker + share_plus | Importação/exportação de backup |

---

## Arquitetura

```
lib/
├── core/           # Tema, utilitários
├── data/           # Database (Drift), serviços, codec de backup
├── domain/         # Entidades e lógica de negócio
├── presentation/   # Pages, widgets, navegação (GoRouter)
├── services/       # Serviços externos (Google Drive, etc.)
└── state/          # Providers Riverpod
```

---

## Funcionalidades Principais

- **CRUD de lembretes** com categorias predefinidas (Pessoal, Saúde, Financeiro, Documentos, Veículo)
- **Persistência local** com banco SQLite via Drift
- **Backup/Restore** em formato JSON
- **Sincronização com Google Drive** (sem Firebase)
- **Navegação adaptativa** com Drawer (mobile) e NavigationRail (tablet)
- **Seed automático** de dados de exemplo na primeira execução

---

## Scripts

- `scripts/run_android.ps1` — Inicializa emulador e executa o app no Android

---

## Build

```bash
flutter pub get
flutter build apk --release
# Saída: build/app/outputs/flutter-apk/app-release.apk
```
