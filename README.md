# Juego de cartas UNO (Backend en Rails)

## ¿Cómo ejecutar?
1) Instalar dependencias:
   _bundle install_
3) Correr servidor:
   _rails server_

## Diagrama de clases
![](./DiagramaClases.jpg)

## Endpoints

| Method HTTP | Endpoint             | Request Body | Description                      | Authorization requered | Response body | 
|-------------|----------------------|------|----------------------------------|------------------------|---------------------|
| POST | /v1/users/register | {"name": "foo", "email": "foo@foo.com", "password": "foo1234"} | Registrarse | No | {"user_id": 3, "token": "PVz_Nljg7s9AEXp8bsP0w"} |
| POST | /v1/users/login | {"email": "foo@foo.com", "password": "foo1234"} | Iniciar sesión | No | {"user_id": 3, "token": "PVz_Nljg7s9AEXp8bsP0w"} |
| GET | /v1/users/logout | - | Cerrar sesión | Yes | - |
| PUT | /v1/users/password | {"current_password": "foo1234", "new_password": "foo0000"} | Cambiar la contraseña | Yes | - | 
| POST | /v1/users/image | {"image": "..."} | Agregar imágen de perfil | Yes | - |
| GET | /v1/users/:id | - | Obtener información del usuario | Yes | {"name": "", "email": "", "image_url": "..."} |
| POST | /v1/games | {“max_groups”: 2} | Crear partida | Yes | {"game_token": "d6gWgq"} |
| GET | /v1/games | - | Obtener mis partidas | Yes | {my_games: [{"game_token": "d6gWgq",}, ...], other_games: [{"game_token": "d6gWgq", ...}, {"game_token": "…", ...}, ...]} |
| GET | /v1/games/:token | - | Obtener información de la partida | Yes | {"max_groups": 2, "administrator_id": 2, "finished": False, "joined": True} |
| PUT | /v1/games/:token | - | Finalizar partida | Yes | - | 
| POST | /v1/games/:token/teams | {"team_name": "foo"} | Crear un equipo para una partida | Yes | {"team_id": 7} |
| GET | /v1/games/:token/teams | - | Obtener la lista de equipos para una partida | Yes | {"teams": [{"id": 1,"name": "foo 1", ...}, {"id": 1,"name": "foo 2", ...}]} |
| PUT | /v1/games/:token/teams/:team_id | - | Unirse a una partida como equipo | Yes | - |
| POST | /v1/games/:token/users/ | - | Unirse a una partida como usuario | Yes | - |
| GET | /v1/games/:token/scores |  | Obtener lista de usuarios y grupo al que pertenecen (en caso de que lo tengan) | Yes | {"users": [{"id": 3,"team": {"id": 3, "name": "foo 2"}}, ...]} |
| GET | /v1/games/:token/scores | - | Ver score de todos los jugadores/grupos (según corresponda) | Yes | {“scores”: [{“id”: 4, “name”: ”foo”, ”score”: 4}, ...]} |
| PUT | /v1/games/:token/scores/:id | - | Incrementar score | Yes | - |
| GET | /v1/games/:token/cards/:user_id | - | Obtener cartas de un usuario | Yes | {"amount_cards":2, "cards": [{"id": 7,"url": "/..."}, {"id": 6, "url": "/..."}]} |
| POST | /v1/games/:token/cards | - | Tomar una carta del mazo  | Yes | {"card": {"id": 7, "url": "/..."}} |
| PUT | /v1/games/:token/cards/:card_id | - | Tirar una carta | Yes | - |
| GET | /v1/games/iGO2Oj/card | - | Obtener ultima carta tirada a la mesa | Yes | {"card": {"id": 7, "url": "/..."}} |
| PUT | /v1/games/:token/cards | - | Restablecer la partida (cartas de los jugadores) | Yes | - |
| DELETE | /v1/users | - | Eliminar cuenta | Yes | - |
