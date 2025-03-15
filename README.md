# Aplicativo de Gestão de Equipes de Voluntários

## Escopo Detalhado

O projeto consiste no desenvolvimento de um aplicativo móvel para gestão de equipes de voluntários, onde cada equipe possui um líder responsável por cadastrar voluntários e gerenciar um calendário exclusivo para a equipe. O líder pode adicionar eventos, tarefas e atualizar o calendário, enquanto os voluntários podem visualizar as atividades agendadas e receber notificações. O aplicativo visa facilitar a organização e a comunicação dentro de grupos de voluntários.

## Requisitos Funcionais (RF) e Não Funcionais (RNF)

### Requisitos Funcionais (RF):

- Cadastro e autenticação de usuários (líderes e voluntários).
- Criação e gerenciamento de grupos de voluntários (apenas líderes).
- Adição e remoção de voluntários em grupos (apenas líderes).
- Criação, edição e exclusão de eventos no calendário da equipe (apenas líderes).
- Visualização do calendário da equipe por voluntários.
- Notificações push para avisos sobre eventos e atualizações no calendário.
- Perfil de usuário com informações básicas e histórico de participação.

### Requisitos Não Funcionais (RNF):

- O aplicativo deve ser desenvolvido para iOS.
- O tempo de carregamento das páginas deve ser inferior a 3 segundos.
- O banco de dados deve ser seguro e escalável.
- O código deve seguir as boas práticas de desenvolvimento (clean code).
- O aplicativo deve funcionar offline para visualização do calendário (com sincronização ao reconectar).

## Pilha Tecnológica

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore e Autenticação)
- **Banco de Dados:** Firestore (NoSQL)
- **Autenticação:** Firebase Authentication
- **Notificações:** Firebase Cloud Messaging (FCM)
- **Calendário:** Biblioteca table_calendar para Flutter.
- **Versionamento:** Git/GitHub
- **Hospedagem:** Firebase Hosting

## Metodologia

O projeto será desenvolvido utilizando a metodologia ágil Scrum, com sprints de 2 semanas. Serão realizadas reuniões diárias para acompanhamento do progresso. O versionamento do código será feito no GitHub. As funcionalidades serão priorizadas com base no backlog do produto.

## Link do Repositório

[Repositório no GitHub](https://github.com/anthonivs/TCC)