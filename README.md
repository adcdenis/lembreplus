# LembrePlus

Aplicativo Flutter para gerenciamento de lembretes com navegação moderna, persistência local e suporte a backup/restauração em JSON. O projeto está pronto para distribuição em Android (APK) e Web.

## Estrutura do projeto

```
lembreplus/
├─ lib/
│  ├─ presentation/
│  │  ├─ pages/                # Telas (Home, Backup, Formulários)
│  │  ├─ widgets/              # AppShell (Drawer/NavigationRail), componentes
│  │  └─ navigation/           # Rotas com GoRouter
│  ├─ data/                    # Serviços, banco (Drift), codec de backup
│  ├─ state/                   # Providers (Riverpod)
│  └─ utils/                   # Utilitários diversos
├─ test/                       # Testes de navegação, backup e formulários
├─ android/                    # Projeto Android (Gradle)
├─ web/                        # Configurações web
├─ build/                      # Artefatos gerados (após builds)
└─ pubspec.yaml                # Dependências e configurações do Flutter
```

## Instalação

1. Pré-requisitos:
   - `Flutter` 3.24+ (canal stable) e `Dart` 3.8+
   - Android SDK/NDK para build Android
   - Chrome para rodar/testar web

2. Instalar dependências:
   ```bash
   flutter pub get
   ```

3. Rodar em desenvolvimento:
   ```bash
   # Web
   flutter run -d chrome

   # Android (emulador/dispositivo)
   flutter run -d android
   ```

## Comandos

- `flutter pub get` — instala dependências
- `flutter test` — executa a suíte de testes
- `flutter build apk` — gera APK release em `build/app/outputs/flutter-apk/app-release.apk`
- `flutter build web` — gera build web estático em `build/web/`

### Notas de build Android

Se houver aviso de NDK, defina a versão no `android/app/build.gradle.kts`:

```kotlin
android {
    ndkVersion = "27.0.12077973"
}
```

## Dependências principais

- `flutter_riverpod` — gerenciamento de estado
- `go_router` — navegação declarativa
- `drift` — ORM/SQL para persistência local
- `sqlite3_flutter_libs` — binários do SQLite
- `path_provider` — diretórios da aplicação
- `shared_preferences` — preferências simples
- `freezed_annotation` + `freezed` — modelos imutáveis e geração de código
- `json_serializable` + `json_annotation` — serialização JSON
- `intl` — internacionalização (ex.: `pt_BR`)
- `file_picker` — seleção de arquivos (web/mobile)
- `fluttertoast` — feedback ao usuário

Dev dependencies:

- `build_runner`, `drift_dev`, `freezed`, `flutter_lints`

## Testes

Execute:

```bash
flutter test
```

Cobrem:

- Navegação via `Drawer`/`NavigationRail` para páginas principais
- Integração de backup com parsing flexível de datas
- Validações de formulário (ex.: contador exige nome, ação via `Icons.save`)

## Backup e restauração

Na aplicação:

- Abra o menu (`Drawer`) e vá em `Backup`
- Exportar: gera arquivo JSON com dados persistidos
- Importar: seleciona um arquivo JSON compatível e restaura dados

Plataformas:

- Android/iOS: o serviço grava/ler do diretório de documentos da aplicação (`getApplicationDocumentsDirectory`) com nome padrão `lembre_backup.json`
- Web: exporta via download do navegador e importa via seletor de arquivos (sem caminho fixo)

Codec de backup:

- Suporta `DateTime` tanto em ISO strings quanto em inteiros epoch (compatível com serializer do Drift)

## Artefatos de distribuição

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Web: `build/web/` (sirva via qualquer HTTP server ou GitHub Pages)

## Conclusão

Projeto pronto para distribuição. Para publicar:

- Android: assine o APK/AAB com sua keystore e publique na Play Store
- Web: disponibilize o conteúdo de `build/web/` em seu servidor/CDN


Gerar APK

- Para um APK de release (instalação manual ou distribuição fora da Play Store):
```
flutter build apk --release
```
- Arquivo gerado: build\app\outputs\apk\release\app-release.apk
- Para um APK de debug (instalação rápida para testes):
```
flutter build apk --debug
```
- Arquivo gerado: build\app\outputs\apk\debug\app-debug.apk
- Para reduzir tamanho (um APK por ABI):
```
flutter build apk --release 
--split-per-abi
```
- Arquivos gerados: build\app\outputs\apk\release\app-*-release.apk (por ABI)
- Abrir a pasta dos APKs no Explorer:
```
explorer .
\build\app\outputs\apk\release
```
AAB (Play Store)

- O formato recomendado para publicação na Play Store:
```
flutter build appbundle --release
```
- Arquivo gerado: build\app\outputs\bundle\release\app-release.aab
Notas rápidas

- Execute flutter doctor para verificar o ambiente Android antes de compilar.
- Para publicar na Play Store, configure assinatura de release (keystore e key.properties ) e a seção de signingConfigs no android/app/build.gradle.kts . Posso te guiar nessa configuração se quiser.
