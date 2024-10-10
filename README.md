# POC TEMPLATE - NextJS version

This repo is a template POC, that will be used for initializing future POCs easier.

- Inspired by: [POC Template](https://github.com/MystenLabs/poc-template)

### Quickstart
- To be able to connect with the vercel KV storage in the local development environment:
  - install vercel cli
  - run `vercel link` in the root directory of the project
  - select `Mysten Labs`
  - link to existing project
  - run `vercel env pull app/.env.development.local`
    - the created `app/.env.development.local` file should have the same format with the `app/.env.development.local.example` directory

- to start the development server of the NextJS app using docker:
  - docker compose up
- to start the development server of the NextJS app without docker:
  - cd app
  - pnpm i
  - pnpm run dev
- to start exploring the template:
  - visit localhost:3000
  - login with your gmail account

### Root Directories structure

- move:

  - Contains the Move code of the smart contracts
  - Contains a sample package named `poc` where the developer can add a move module and start building

- app

  - Contains a Typescript NextJS App, with ready-to-use:
    - three (four) different `user roles`:
      - admin
      - moderator
      - member
      - (anonymous user)
    - routing based on the permissions of the current user
    - `api` directory, to utilize vercel serverless functions upon deployment
    - integration with [Vercel KV](https://vercel.com/docs/storage/vercel-kv/quickstart) for having a persistent storage without managing the deployment of a database
    - `Sui TS SDK` integration
    - `Sui Enoki` integration
    - `Progressive Web App (PWA)` setup
    - `Responsive` layout for large and small sreens

- setup
  - A Typescript project, with ready-to-use:
    - environment variable (.env) file reading
    - Sui SDK integration
    - publish shell script

---

For more details on each sub-project, head to the README files under the corresponding directories 

