# jira_description_helper

Gerador de descrição para cards do Jira, desenvolvido em **Flutter Web**, com **deploy automático** via **GitHub Actions** para o **GitHub Pages**.

---

## 🚀 Como funciona o deploy

O deploy é feito **automaticamente** através de uma pipeline configurada no arquivo `.github/workflows/pages.yml`.  
Sempre que você fizer um **push** na branch `main`, o GitHub Actions irá:

1. **Buildar** o projeto Flutter Web.
2. Gerar os arquivos finais na pasta `build/web`.
3. Publicar automaticamente o resultado no **GitHub Pages**.

---

## ⚙️ Passo 1 — Configurar Pages no GitHub

Antes de tudo, é necessário habilitar o GitHub Pages para usar o deploy via Actions:

1. Vá em **Settings → Pages** no repositório do GitHub.  
2. Na seção **Build and deployment**, configure:
   - **Source = GitHub Actions**

> ⚠️ Este passo só precisa ser feito **uma vez** no repositório.

---

## 🛠️ Passo 2 — Configurar ambiente local

Se for a primeira vez que está buildando Flutter Web no seu ambiente:

```bash
flutter config --enable-web
flutter pub get
```

---

## 📦 Deploy automático

Após configurar tudo, basta enviar alterações para a branch `main`:

```bash
git add .
git commit -m "feat: atualização do app"
git push origin main
```

Isso disparará automaticamente a pipeline do GitHub Actions, que irá buildar e publicar a nova versão.

---

## 🔍 Acompanhando o deploy

1. Vá na aba **Actions** do repositório no GitHub.
2. Localize a execução com o nome **Deploy Flutter Web to GitHub Pages**.
3. Aguarde até que o status fique **verde (Success)** ✅.
4. Quando finalizado, a aplicação estará disponível em:

```
https://SEU_USUARIO.github.io/jira_description_helper/
```

---

## 💡 Observações importantes

- **Base Href correto:**
  - Para **Project Page**: `https://SEU_USUARIO.github.io/jira_description_helper/`
    ```bash
    --base-href "/jira_description_helper/"
    ```
  - Para **User/Org Page**: `https://SEU_USUARIO.github.io`
    ```bash
    --base-href "/"
    ```

- **Fluxo de build:**
  - `git push` na branch `main` → job `build` roda → gera `build/web` → envia artefato → job `deploy` publica no GitHub Pages.

- **Conflitos e pushes seguidos:**
  - A configuração `concurrency` do workflow cancela builds antigos se você fizer vários pushes em sequência.

- **Debug de falhas:**
  - Se algo falhar, abra a aba **Actions**, clique no job e analise os logs de cada etapa, principalmente do passo **Build Flutter Web**.

---

## 🧪 Testando build localmente (opcional)

Se quiser testar antes de publicar:

```bash
flutter build web --release --base-href "/jira_description_helper/"
```

Os arquivos finais ficarão na pasta `build/web`.  
Abra com um servidor local (exemplo: **Live Server** no VS Code) para visualizar.

---

Agora, basta **desenvolver**, fazer **push na branch main** e acompanhar na aba **Actions**.  
A publicação no GitHub Pages será feita **sem intervenção manual**. 🚀
