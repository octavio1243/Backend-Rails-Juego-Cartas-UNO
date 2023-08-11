# Juego de cartas UNO (Backend en Rails)

## Diagrama de clases
![](./DiagramaClases.jpg)

## Endpoints

| Method HTTP | Endpoint             | Request Body | Description                      | Authorization requered | Response body | 
|-------------|----------------------|------|----------------------------------|------------------------|---------------------|
| POST | /v1/users/register | {"name":"foo","email":"foo@foo.com","password":"foo1234"} | Registrarse | No | {“user_id”:3,“token”:”PVz_Nljg7s9AEXp8bsP0w”} |
| POST | /v1/users/login | {"email":"foo@foo.com","password":"foo1234"} | Iniciar sesión | No | {“user_id”:3,“token”:”PVz_Nljg7s9AEXp8bsP0w”} |
| GET | /v1/users/logout | - | Cerrar sesión | Yes | - |
| PUT | /v1/users/password | {"current_password": "foo1234","new_password": "foo0000"} | Cambiar la contraseña | Yes | - | 
| POST | /v1/users/image | {"image": “”} | Agregar imágen de perfil | Yes | - |
| GET | /v1/users/:id | - | Obtener información del usuario | Yes | {"name":"","email":"","image_url":"..."} |
| POST | /v1/games | {“max_groups”: 2} | Crear partida | Yes | {"game_token": "d6gWgq"} |
| GET | /v1/games | - | Obtener mis partidas | Yes | {my_games:[{"game_token": "d6gWgq",},…],other_games: [{"game_token": "d6gWgq",},{"game_token": "…",},…]} |
| GET | /v1/games/:token | - | Obtener información de la partida | Yes | {“max_groups”: 2,“administrator_id”: 2,“finished”: False,“joined”: True} |
| PUT | /v1/games/:token | - | Finalizar partida | Yes | - | 

|  |  |  |  | Yes |
|  |  |  |  | Yes |
|  |  |  |  | Yes |
|  |  |  |  | Yes |
|  |  |  |  | Yes |
|  |  |  |  | Yes |
|  |  |  |  | Yes |
|  |  |  |  | Yes |
|  |  |  |  | Yes |
