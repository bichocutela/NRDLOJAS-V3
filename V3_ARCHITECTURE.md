# NRD Lojas V3

## Direção técnica

- Flutter é a camada principal de interface e navegação.
- Material 3 é a base visual.
- Glass Soft é implementado em Flutter com transparência, blur, bordas e sombras.
- Jetpack Compose fica reservado para telas/recursos nativos Android que realmente precisem de Android APIs.
- A comunicação Flutter <-> Android será feita por MethodChannel/Pigeon.

## Layout mapeado do V2

A Home do V2 foi usada como referência funcional e visual:

1. Banner superior arredondado.
2. Menu no canto esquerdo e notificações no canto direito.
3. Campo de pesquisa com busca por texto/voz.
4. Botão principal Pesquisar.
5. Categorias.
6. Mais Utilizados com carrossel horizontal.
7. Últimos Adicionados.
8. Histórico Recente.
9. Meus Favoritos.
10. Drawer com Promoções, Configurações, Sobre e Administração.

## Fase atual

O V3 já possui uma primeira implementação Flutter da Home e do Glass Soft em `lib/`.

Os dados exibidos nesta fase são demonstrativos. A próxima etapa é migrar os repositórios/serviços do V2 para Dart e ligar:

- produtos reais;
- pesquisa real;
- categorias reais;
- Mais Utilizados global;
- Últimos Adicionados;
- histórico;
- favoritos;
- notificações;
- Firebase/Supabase;
- aparência remota;
- painel administrativo.

## Compose no V3

O arquivo `lib/src/native/native_bridge.dart` define o canal `nrdlojas/native`.

Depois da geração do host Android Flutter, o `MainActivity.kt` deverá registrar esse canal e poderá abrir Activities em Jetpack Compose para recursos nativos específicos. Não é recomendado duplicar em Compose as mesmas telas que já são renderizadas pelo Flutter.

## Regra de segurança do projeto

O repositório V2 permanece separado. Mudanças do V3 não devem modificar assinatura, versionamento ou código de produção do V2.
