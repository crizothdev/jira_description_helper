# jira_description_helper

Gerador de descrição para cards do Jira (Flutter Web) com deploy automático no **GitHub Pages**.

## Como funciona o deploy

Usamos **GitHub Actions** para buildar e publicar o `build/web` no Pages a cada `push` na branch `main`.

### Passo 1 — Habilitar Pages para Actions
1. No GitHub, acesse **Settings → Pages**  
2. Em **Build and deployment**, selecione **Source = GitHub Actions**.

> O workflow já está em `.github/workflows/pages.yml`.

### Passo 2 — Primeiro build e push
No seu ambiente local (apenas se ainda não habilitou web ou não baixou deps):

```bash
flutter config --enable-web
flutter pub get
