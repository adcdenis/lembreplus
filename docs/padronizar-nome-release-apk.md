# Padronização do nome do APK de release

Padroniza o arquivo gerado no release para o formato:

`NomeApp-<versão>-<AAAAmmdd_HHMMss>.apk`

- `NomeApp`: lido do `android:label` no `AndroidManifest.xml`
- `versão`: lida de `version` no `pubspec.yaml` (apenas a parte antes do `+`)
- `AAAAmmdd_HHMMss`: data e hora do build

## Passo a passo (Kotlin DSL)

Arquivo: `android/app/build.gradle.kts`

Cole ao final do arquivo:

```kotlin
tasks.register("renameReleaseApk") {
    group = "build"
    dependsOn("assembleRelease")
    doLast {
        // Nome do app a partir do AndroidManifest
        val manifestText = project.file("src/main/AndroidManifest.xml").readText()
        val label = Regex("android:label=\"([^\"]+)\"")
            .find(manifestText)
            ?.groupValues?.get(1) ?: "App"

        // Versão do pubspec (usa apenas a parte antes do '+')
        val pubspecText = rootProject.file("../pubspec.yaml").readText()
        val versionRaw = Regex("version:\\s*([\\w\\.\\-\\+]+)")
            .find(pubspecText)
            ?.groupValues?.get(1) ?: "0.0.0+1"
        val version = versionRaw.split('+').first()

        // Timestamp
        val timestamp = java.text.SimpleDateFormat("yyyyMMdd_HHmmss")
            .format(java.util.Date())

        // Nome final
        val newName = "${label}-${version}-${timestamp}.apk"

        // Copia do APK padrão gerado pelo Gradle
        val outputsDir = layout.buildDirectory.dir("outputs/apk/release").get().asFile
        val standardApk = outputsDir.resolve("app-release.apk")
        if (standardApk.exists()) {
            standardApk.copyTo(outputsDir.resolve(newName), overwrite = true)
        }

        // Copia do APK gerado pelo Flutter
        val flutterApkDir = rootProject.layout.buildDirectory
            .dir("app/outputs/flutter-apk").get().asFile
        val flutterApk = flutterApkDir.resolve("app-release.apk")
        if (flutterApk.exists()) {
            flutterApk.copyTo(flutterApkDir.resolve(newName), overwrite = true)
        }
    }
}

afterEvaluate {
    tasks.findByName("assembleRelease")?.finalizedBy(tasks.findByName("renameReleaseApk"))
}
```

## Como usar

- Execute `flutter build apk --release` na raiz do projeto.
- Alternativa (executar manualmente a tarefa): `./gradlew :app:renameReleaseApk` dentro da pasta `android/`.

## Saída esperada

- `android/app/build/outputs/apk/release/NomeApp-<versão>-<data_hora>.apk`
- `build/app/outputs/flutter-apk/NomeApp-<versão>-<data_hora>.apk`

## Observações

- Se preferir evitar caracteres como `+` ou espaços no nome, substitua `label` por um nome fixo (ex.: `LembrePlus`) ao montar `newName`.
- Compatível com Kotlin DSL e AGP 8.x. Para projetos em Groovy (`build.gradle`), a sintaxe muda, mas a lógica é a mesma.
