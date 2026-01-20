# next_health_hub

Este projeto é um aplicativo móvel desenvolvido em **Flutter**, focado em performance e escalabilidade, seguindo padrões de arquitetura limpa e modular.

## 📱 Requisitos de Compatibilidade

O aplicativo foi desenvolvido e otimizado seguindo as diretrizes das lojas (Google Play e App Store) vigentes em **2025**.

### Android
* **Versão Mínima:** Android 6.0 (API 23 - Marshmallow)
* **Versão Alvo (Target):** Android 15 (API 35)
* **Arquitetura Suportada:** arm64-v8a, armeabi-v7a, x86_64

### iOS
* **Versão Mínima (Deployment Target):** iOS 13.0
* **Compatibilidade:** Otimizado para iOS 18/19
* **Dispositivos:** iPhone 6s e superiores

---

## 🛠️ Ambiente de Desenvolvimento

Para rodar este projeto, certifique-se de ter o ambiente configurado com as seguintes versões (ou superiores):

* **Flutter:** 3.24.0 ou superior (Channel stable)
* **Dart:** 3.x
* **Java (JDK):** 17 (Requerido para o Gradle atual)
* **Cocoapods:** Última versão estável (para iOS)

## ⚙️ Configuração do Ambiente (.env)

O projeto utiliza o pacote `flutter_dotenv` para gerenciar configurações sensíveis e variáveis de ambiente.

1.  Localize o arquivo `.env_example` na raiz do projeto.
2.  Crie uma cópia e renomeie para `.env`:
    cp .env_example .env
3.  Configure as variáveis de ambiente no arquivo `.env`.

## 📱 Configuração do Firebase (Android)

O projeto já inclui o arquivo `android/app/google-services.json` configurado para o ambiente de desenvolvimento/homologação atual.

Caso você deseje utilizar um novo projeto do Firebase ou alterar as credenciais:

1. Acesse o [Console do Firebase](https://console.firebase.google.com/).
2. Crie um novo projeto ou selecione um existente.
3. Adicione um app Android ao projeto com o ID do pacote correspondente (ex: `com.exemplo.app`).
4. Faça o download do arquivo `google-services.json`.
5. Substitua o arquivo existente em:  
   `android/app/google-services.json`

> **Nota:** Certifique-se de que o `applicationId` no seu `android/app/build.gradle` corresponde ao que foi configurado no console do Firebase.

## 🚀 Instalação e Execução

1.  **Clonar o repositório:**
    ```bash
    git clone https://github.com/guilhermebilbao/next-health-hub-flutter/
    cd next-health-hub-flutter
    ```

2.  **Instalar dependências:**
    ```bash
    flutter pub get
    ```

3.  **Executar em modo Debug:**
    ```bash
    flutter run
    ```

---

## 📦 Compilação e Deploy (Build)

### Android (Geração de AAB/APK)
*Este passo pode ser executado em ambientes Windows, Linux (Fedora/Ubuntu) ou macOS.*

Para gerar o **App Bundle (.aab)** (Recomendado para Google Play):
```bash
flutter build appbundle --release