# Tony — assistente geral

Assistente pessoal geral, inicialmente conectado ao WhatsApp. A ideia é receber mensagens e arquivos, validar origem e exceções, enfileirar eventos e responder usando contexto e uma base vetorial de acontecimentos.

## Estado inicial

- PostgreSQL 17 com pgvector.
- Evolution GO conectado ao PostgreSQL para autenticação e usuários.
- A API do Evolution fica acessível somente na máquina local, em `http://127.0.0.1:4000`.
- PostgreSQL não publica porta no host nem na LAN; os serviços usam uma rede Docker interna.

## Inicialização local

1. Copie `.env.example` para `.env` e defina senhas/chaves fortes. O `.env` é local e não deve ser versionado.
2. Instale as regras do host e as unidades systemd (como root):

   ```sh
   ./infra/install-host.sh
   ```

O instalador para e recria os containers e redes da stack, preservando os volumes. Depois da instalação, o systemd controla os dois serviços e aplica o firewall antes de iniciá-los. Não use `docker compose up` diretamente para operar a stack.

Use `systemctl start|stop|restart tony-stack` para operar a stack e `journalctl -u tony-stack -f` para acompanhar os logs. Reinícios do Docker também reiniciam o firewall e a stack na ordem correta.

O PostgreSQL cria os bancos `tony`, `evogo_auth` e `evogo_users`. A extensão `vector` fica habilitada no banco `tony`. Os scripts de `postgres/init` só rodam na primeira criação do volume; para reaplicá-los em um ambiente descartável, remova o volume com `docker compose down -v` (isso apaga os dados).

O Evolution GO requer ativação de licença para liberar as rotas da API. Depois de iniciar, siga o fluxo do Manager em `http://127.0.0.1:4000/manager/login`, usando a chave configurada em `EVOLUTION_API_KEY`.

## Acesso e segurança

O PostgreSQL permanece em uma rede Docker `internal`, sem porta publicada nem saída para a internet. O Evolution também participa de uma rede de saída IPv4 dedicada; regras no `DOCKER-USER` bloqueiam destinos privados, locais, reservados e diretamente conectados. O host bloqueia conexões novas dos containers Tony aos seus serviços. IPv6 fica desativado na rede de saída. A API continua publicada apenas em `127.0.0.1:4000`.

## Próximas etapas

- Validar o fluxo de mensagens e webhooks do Evolution GO.
- Criar o orquestrador do assistente e o processamento de eventos.
- Adicionar Redis para filas e memória temporária.
- Definir o modelo de dados vetorial em `tony`.
- Adicionar Discord para notificações operacionais.

## Referências

- [Evolution GO — repositório oficial](https://github.com/evolution-foundation/evolution-go)
- [Deploy Docker do Evolution GO](https://github.com/evolution-foundation/evolution-go/blob/main/docs/wiki/deploy-producao/docker-deployment.md)
