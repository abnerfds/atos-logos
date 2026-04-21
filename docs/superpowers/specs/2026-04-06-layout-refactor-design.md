# Layout Refactor - Design Spec

**Data:** 2026-04-06
**Abordagem:** Full-Stack por tela (Abordagem C)
**Metodologia:** TDD clássico (red-green-refactor)

---

## 1. Visão Geral

Refazer o layout visual de 5 telas existentes do app mobile Atos Logos para ficarem fiéis aos designs fornecidos em `.ai_docs/assets`. Ajustar backend com endpoints novos onde necessário. Cobertura de testes 100%.

### Telas no escopo

1. Login (refactor visual)
2. Registro de Sede (refactor visual)
3. Dashboard/Início (backend + mobile)
4. Secretaria/Membros (refactor visual + busca)
5. Cadastro de Membro (refactor visual)

### Fora do escopo (placeholder "Em breve")

- Aba Agenda
- Aba Gestão
- Aba Notificações
- Sub-abas Visitantes e EBD na Secretaria
- Drawer do hamburger menu

---

## 2. Arquitetura e Navegação

### Navegação inferior: 4 → 5 abas

| # | Aba | Ícone | Conteúdo |
|---|-----|-------|----------|
| 1 | Início | Home | Dashboard com carteirinha flip, aniversariantes, eventos |
| 2 | Secretaria | People | Lista de membros (Membros ativo, Visitantes/EBD = "Em breve") |
| 3 | Agenda | Calendar | Placeholder "Em breve" |
| 4 | Gestão | Groups | Placeholder "Em breve" |
| 5 | Notificações | Bell | Placeholder "Em breve" |

### Componente ComingSoonPage

Widget reutilizável para todas as telas/abas sem funcionalidade:
- Ícone suave centralizado
- Texto "Em breve" + subtítulo "Estamos trabalhando nessa funcionalidade"
- Segue design system Serene Steward

### AppBar padronizado

- **Esquerda:** Hamburger menu + "Atos Logos" (lado a lado)
- **Direita:** Avatar do usuário com inicial

---

## 3. Backend - Novos Endpoints

### 3.1 `GET /auth/me`

Retorna perfil completo do usuário autenticado para carteirinha e header.

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "name": "Ricardo Oliveira",
    "email": "ricardo@email.com",
    "phone": "11999999999"
  },
  "profile": {
    "photoUrl": "https://...",
    "admissionDate": "2020-03-15",
    "birthDate": "1990-05-20",
    "registrationNumber": "001"
  },
  "membership": {
    "role": "ADMIN",
    "status": "ACTIVE"
  },
  "positions": [
    { "id": "uuid", "name": "Pastor" }
  ],
  "church": {
    "id": "uuid",
    "name": "Igreja Batista Central"
  },
  "branch": {
    "id": "uuid",
    "name": "Sede Principal"
  }
}
```

**Localização:** `auth.controller.ts` usando `@CurrentUser()` decorator existente.

### 3.2 `GET /member-profiles/birthdays`

Aniversariantes do mês.

**Query params:** `?month=4` (opcional, default = mês atual)

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Ana Paula",
      "photoUrl": "https://...",
      "birthDate": "1995-04-12"
    }
  ],
  "month": 4
}
```

**Implementação:** Filtro Prisma no service usando extração de mês do campo `birthDate`.

### 3.3 Filtro `upcoming` no `GET /events` existente

**Query params adicionais:** `upcoming=true`

**Comportamento:** Filtra `startsAt >= now()`, ordena ASC (mais próximo primeiro). Compatível com filtros existentes (`type`, `page`, `limit`).

**Exemplo:** `GET /events?upcoming=true&limit=5`

---

## 4. Mobile - Telas em Detalhe

### Design System (Serene Steward)

- **Primary:** #37628A (teal)
- **Surfaces:** #F7F9FC → #DCD3E9
- **Fonts:** Manrope (headlines), Inter (body)
- **Corners:** 4px (sm), 8px (md), 12px (lg), 16px (xl)
- **Regra no-line:** Sem borders/dividers, separação por cor de fundo

### 4.1 Login

- Ícone circular azul claro + "Atos Logos" em teal
- Título "Bem-vindo de Volta" (Manrope)
- Subtítulo "Por favor, insira suas credenciais" (cinza)
- Campo E-MAIL — fundo #F0F4F8, cantos arredondados, label uppercase
- Campo SENHA — mesmo estilo, toggle visibilidade (ícone olho)
- Link "Esqueceu a senha?" alinhado à direita
- Botão "Entrar →" — teal escuro, largura total
- Footer: PRIVACIDADE | TERMOS | SUPORTE
- "Não tem uma conta ainda? Converse com o Administrador"
- **Backend:** sem mudança (`POST /auth/login` existente)

### 4.2 Registro de Sede

- Logo "Atos Logos" no topo
- Título "Criar Conta da Igreja" (Manrope bold)
- Subtítulo explicativo
- Campos: NOME DA SUA SEDE, NOME DO PASTOR/LÍDER, E-MAIL, SENHA (toggle), CONFIRMAR SENHA (toggle)
- Botão "Criar Conta →"
- Link "Já tem uma conta? Entre aqui"
- **Backend:** sem mudança (`POST /auth/signup` existente)

### 4.3 Dashboard/Início

- **AppBar:** Hamburger + "Atos Logos" (esquerda), Avatar (direita)
- **Saudação:** "Olá, {nome}" + "Bem-vindo ao seu painel de controle"
- **Carteirinha Flip:**
  - Animação de flip (frente/verso)
  - Frente: fundo teal escuro, avatar, nome, cargo eclesiástico, "Membro da Igreja"
  - Verso: igreja, data de admissão, nº registro, status
  - Dados: `GET /auth/me`
- **Aniversariantes do Mês:**
  - Seção colapsável
  - Lista horizontal de avatares com nome
  - Dados: `GET /member-profiles/birthdays`
- **Próximos Eventos:**
  - Lista vertical de cards
  - Cada card: dia (número destaque), título, horário
  - Dados: `GET /events?upcoming=true&limit=5`

### 4.4 Secretaria/Membros

- **AppBar:** padrão
- **Título:** "Secretaria" + "Gerencie membros e voluntários"
- **3 abas:** Membros (ativo) | Visitantes ("Em breve") | EBD ("Em breve")
- **Aba Membros:**
  - Campo busca: "Buscar por nome ou cargo..."
  - Lista: avatar circular, nome, cargo/posição
  - Sem linhas divisórias, espaçamento generoso
- **FAB:** Botão lavanda/roxo "+" canto inferior direito para adicionar membro
- **Dados:** `GET /member-profiles` existente

### 4.5 Cadastro de Membro

- **AppBar:** padrão
- **Título:** "Novo Membro" + subtítulo
- **Avatar:** Placeholder circular teal + "Foto do Perfil"
- **Seção colapsável "Informações Pessoais":**
  - NOME COMPLETO, E-MAIL, CEP, TELEFONE
  - DATA DE NASCIMENTO (ícone calendário)
  - DATA DE MEMBRO/BATISMO (ícone calendário)
- **Seção "Dados Obrigatórios":** Checklist colapsável
- **Dados:** `POST /member-profiles` existente

---

## 5. Estratégia de Testes (TDD)

### Princípio

Testes escritos ANTES da implementação. Cada teste descreve UM comportamento específico com nomenclatura clara.

### 5.1 Backend (Jest)

```
describe('AuthController - GET /auth/me')
  it('should return full profile for authenticated user')
  it('should return 401 when not authenticated')

describe('MemberProfilesService - findBirthdays')
  it('should return members with birthday in current month')
  it('should return empty list when no birthdays match')

describe('EventsService - findAll with upcoming filter')
  it('should return only future events sorted by date ASC')
  it('should still support type filter combined with upcoming')
```

- Unit tests no service: lógica de query
- Unit tests no controller: validação de params, guards
- Mocks do Prisma client via `jest.mock`

### 5.2 Mobile - Cubits (bloc_test + mocktail)

```
group('AuthCubit - fetchProfile')
  test('should emit profile loaded when /me succeeds')
  test('should emit error when /me fails')

group('HomeCubit - loadDashboard')
  test('should emit birthdays and upcoming events on success')
  test('should emit error when birthdays fetch fails')

group('MembersCubit - search')
  test('should filter members by name')
  test('should return full list when query is empty')
```

- Estados emitidos (loading → loaded / error)
- Mock de repositories via mocktail
- Edge cases (lista vazia, erro de rede)

### 5.3 Mobile - Widgets (flutter_test)

```
group('LoginPage')
  testWidgets('should show error when email is empty and submit pressed')
  testWidgets('should toggle password visibility')
  testWidgets('should navigate to register on link tap')

group('FlipCard')
  testWidgets('should show front side by default')
  testWidgets('should flip to back on tap')

group('ComingSoonPage')
  testWidgets('should display "Em breve" message')
```

- Renderização dos elementos visuais
- Interações (tap, submit, toggle)
- Navegação entre telas
- Estados de loading/error/empty

### 5.4 Estrutura de arquivos de teste

```
# Backend
src/modules/auth/auth.controller.spec.ts      (novo - /me)
src/modules/auth/auth.service.spec.ts          (atualizar - /me)
src/modules/member-profiles/member-profiles.service.spec.ts  (atualizar - birthdays)
src/modules/events/events.service.spec.ts      (atualizar - upcoming)

# Mobile
test/
├── features/
│   ├── auth/
│   │   ├── cubit/auth_cubit_test.dart         (atualizar)
│   │   └── pages/login_page_test.dart         (novo)
│   ├── home/
│   │   ├── cubit/home_cubit_test.dart         (atualizar)
│   │   ├── pages/home_page_test.dart          (novo)
│   │   └── widgets/flip_card_test.dart        (novo)
│   ├── members/
│   │   ├── cubit/members_cubit_test.dart      (atualizar)
│   │   └── pages/members_page_test.dart       (novo)
│   └── registration/
│       └── pages/register_page_test.dart      (novo)
└── shared/
    └── widgets/coming_soon_page_test.dart     (novo)
```

---

## 6. Ordem de Implementação (Full-Stack por tela)

| Fase | Tela | Backend | Mobile | Testes |
|------|------|---------|--------|--------|
| 1 | Login | - | Refactor visual | Widget + Cubit |
| 2 | Registro de Sede | - | Refactor visual | Widget + Cubit |
| 3 | Dashboard/Início | GET /auth/me, birthdays, upcoming events | Carteirinha flip + seções | Backend services + Cubit + Widget |
| 4 | Secretaria/Membros | - | Refactor visual + busca | Widget + Cubit |
| 5 | Cadastro de Membro | - | Refactor visual | Widget + Cubit |
| Shared | ComingSoonPage + Navegação 5 abas | - | Widget reutilizável | Widget |
