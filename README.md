#  Aplicativo de Gestão de Voluntários ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=white)

---

##  Objetivo

O projeto consiste no desenvolvimento de um aplicativo móvel para gestão de equipes de voluntários, onde cada equipe possui um líder responsável por cadastrar voluntários e gerenciar um calendário exclusivo para a equipe. O líder pode adicionar eventos, tarefas e atualizar o calendário, enquanto os voluntários podem visualizar as atividades agendadas e receber notificações. O aplicativo visa facilitar a organização e a comunicação dentro de grupos de voluntários.

---

##  Escopo

### Incluído 
- Cadastro e autenticação de usuários (Líder e Voluntário).
- Criação e gerenciamento de grupos.
- Calendário exclusivo por grupo.
- Criação e exclusão de eventos pelos líderes.
- Confirmação de presença dos voluntários.
- Notificações push para eventos e escalas.
- Interface adaptada por tipo de usuário.

### Não incluído 
- Sistema de pontuação ou ranking.
- Compartilhamento público de eventos fora do grupo.
- Painel web administrativo.

---

##  Design de Interface

### Decisões de UI/UX
- Visual limpo com cores institucionais (azul e branco).
- Componentes com Material 3.
- Tela inicial com calendário centralizado para facilitar visualização rápida.
- Experiência distinta por tipo de usuário: Líder, Voluntário e Master.

### Protótipos
> 

---

##  Desenvolvimento

###  Tecnologias Utilizadas

#### Frontend
- Flutter (Dart) ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
- Biblioteca [`table_calendar`](https://pub.dev/packages/table_calendar)

#### Backend
- Firebase Authentication ![Firebase Auth](https://img.shields.io/badge/Firebase_Auth-FFCA28?style=flat&logo=firebase&logoColor=white)
- Firebase Firestore (NoSQL)
- Firebase Functions
- Firebase Messaging (FCM)

---

##  Qualidade

- Organização em `models/`, `controllers/`, `views/`, `services/` e `widgets/`
- Boas práticas com `flutter_lints`
- Testes com `flutter_test` (em andamento)
- Uso de `logger` para rastreabilidade de erros

---

##  Contexto

Durante a gestão de voluntários em eventos comunitários, observou-se dificuldade de comunicação entre líderes e participantes. O aplicativo resolve esse problema oferecendo uma plataforma centralizada, com escalas e notificações automáticas.

---

##  Restrições

- Apenas líderes podem editar ou excluir eventos.
- Notificações exigem que o usuário esteja com o app instalado e com permissões habilitadas.
- O app exige conexão para sincronização com o banco de dados (exceto leitura offline do calendário).

---

## Diagramas

### Diagrama de Containers

```mermaid
flowchart TD
    subgraph Dispositivos dos Usuários
        A[Usuário Líder] -->|HTTPS| App["Aplicativo Flutter Android/iOS"]
        B[Usuário Voluntário] -->|HTTPS| App
        C[Usuário Master/Admin] -->|HTTPS| App
    end

    subgraph Aplicativo de Gestão de Voluntários
        App -->|HTTPS| Auth["Firebase Authentication"]
        App -->|HTTPS| Firestore["Firebase Firestore"]
        App -->|HTTPS| Functions["Firebase Functions"]
        App -->|HTTPS| Messaging["Firebase Messaging FCM"]
    end

    subgraph Firebase Backend
        Auth -->|Autentica| Firestore
        Functions -->|Executa Ações em| Firestore
        Messaging -->|Envia Notificações para| App
    end
```

---

### Diagrama de Classes

```mermaid
classDiagram
  class User {
    +String id
    +String name
    +String email
    +String role
    +List~String~ groupIds
    +String phone
    +String occupation
    +String description
  }

  class Group {
    +String id
    +String name
    +String leaderId
    +List~String~ userIds
    +List~String~ volunteers
  }

  class Event {
    +String id
    +String groupId
    +String title
    +DateTime date
    +String description
    +List~String~ confirmedUserIds
  }

  class AuthService {
    +signIn(email, password)
    +signOut()
    +register(user, password)
  }

  class EventController {
    +createEvent(event)
    +deleteEvent(eventId)
    +confirmAttendance(eventId, userId)
  }

  class GroupController {
    +createGroup(group)
    +deleteGroup(groupId)
    +addVolunteer(groupId, userId)
    +removeVolunteer(groupId, userId)
  }

  User --> Group : Participa
  Group --> Event : Possui
  AuthService --> User : Autentica
  EventController --> Event : Gerencia
  GroupController --> Group : Gerencia
```


##  Requisitos de Software

### Funcionais 
- Cadastro e autenticação de usuários (líderes e voluntários).
- Criação e gerenciamento de grupos de voluntários (apenas líderes/master).
- Adição e remoção de voluntários em grupos (apenas líderes/master).
- Criação, edição e exclusão de eventos no calendário da equipe (apenas líderes/master).
- Visualização do calendário da equipe por voluntários.
- Notificações push para avisos sobre eventos e atualizações no calendário.
- Perfil de usuário com informações básicas e histórico de participação.

### Não Funcionais 
- O aplicativo deve ser desenvolvido para iOS e Android.
- O tempo de carregamento das páginas deve ser inferior a 3 segundos.
- O banco de dados deve ser seguro e escalável.
- O código deve seguir as boas práticas de desenvolvimento (clean code).
- O aplicativo deve funcionar offline para visualização do calendário (com sincronização ao reconectar).


---

##  Modelagem

- Arquitetura baseada em MVC com separação clara entre lógica de controle, serviços e UI.
- `Controller` para lógica de negócio (`event_controller.dart`, `group_controller.dart`)
- `Service` para integração com Firebase (`auth_service.dart`, etc.)

---

##  Stacks

| Tecnologia | Badge |
|------------|--------|
| Flutter | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) |
| Firebase | ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=white) |
| Firestore | ![Firestore](https://img.shields.io/badge/Firestore-003B57?style=flat&logo=google-cloud&logoColor=white) |
| GitHub | ![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white) |
| Dart | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white) |

---

##  Testes

- Testes unitários com `flutter_test`
- Planejamento de testes de integração para validação de lógica de eventos e permissões por função.
- Simulação de notificações via Firebase. (em fase de testes)

---

##  Repositório

[🔗 GitHub - anthonivs/TCC](https://github.com/anthonivs/TCC)
