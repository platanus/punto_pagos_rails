# PuntoPagosRails [![Gem Version](https://badge.fury.io/rb/punto_pagos_rails.svg)](http://badge.fury.io/rb/punto_pagos_rails) [![Build Status](https://travis-ci.org/platanus/punto_pagos_rails.svg?branch=master)](https://travis-ci.org/platanus/punto_pagos_rails) [![Coverage Status](https://coveralls.io/repos/github/platanus/punto_pagos_rails/badge.svg)](https://coveralls.io/github/platanus/punto_pagos_rails)

## PuntoPagosRails is no longer maintained.

- We will leave the Issues open as a discussion forum only.
- We do not guarantee a response from us in the Issues.
- We are no longer accepting pull requests.
- We are using this https://github.com/platanus/active_merchant/tree/punto_pagos_gateway

Esta gema es un engine construído sobre [puntopagos-ruby](https://github.com/acidlabs/puntopagos-ruby) con la intención de integrar a una Rails app el flujo de pago básico o más común que podemos encontrar normalmente en una aplicación.

## Instalación

Agrega a tu `Gemfile`

```ruby
gem "puntopagos", git: "https://github.com/acidlabs/puntopagos-ruby.git", ref: "54167cc5d081abd1cb110832af1aebefcf734e78"
gem 'punto_pagos_rails'
```

> Como pueden ver, la gema de puntopagos hace referencia a un commit específico. Este commit es el que permite pasar la configuración de puntopagos como variables ambientales. Como [puntopagos-ruby](https://github.com/acidlabs/puntopagos-ruby) no ha hecho el release que contiene ese cambio, es que necesitamos hacer la referencia al commit manualmente.

Luego, se debe correr el generador

```bash
$ rails generate punto_pagos_rails:install
```

y por último:

```bash
$ bundle install
```

```bash
$ rake db:migrate
```

El instalador hace lo siguiente:

1. Copia la migración que crea la tabla `transactions`. En está tabla se almacenará información sobre los pagos (o intentos de pago) realizados.

2. Crea `/your_app/config/puntopagos.yml`. Este archivo debe modificarse con las credenciales para la comunicación con PuntoPagos.

Una vez que hayamos corrido el instalador, se necesitará crear un **flujo de pago** para un **modelo pagable** de nuestra aplicación.
Un **modelo pagable** es básicamente una clase heredada de `ActiveRecord::Base` que representa un objeto que se puede vender. Por ej: un ticket para un concierto, una cita con el médico, etc. De esta manera, los modelos `Ticket` o `Appointment`, podrían ser buenos ejemplos de **modelo pagable**.

## Flujo de Pago

Para crear un nuevo flujo de pagos, se debe correr el siguiente generador:

```bash
rails generate punto_pagos_rails:payment_flow modelo_pagable controlador
```

Por ejemplo:

```bash
rails generate punto_pagos_rails:payment_flow ticket transactions
```

y luego:

```bash
$ rake db:migrate
```

Tomando `Ticket` como ejemplo de modelo pagable y `transactions` como controlador, el generador hace lo siguiente:

1. Revisa si el modelo `Ticket` existe. Si no existe, lo crea y, en cualquier caso, agrega el atributo `amount`. Amount es el atributo donde configuraremos el valor de una instancia de `Ticket`. Por ej: si hicimos una aplicación para vender tickets para festivales y el valor de un ticket es $100, ese 100 deberá almacenarse en `amount`.

2. Incluye en `Ticket` el mixin: `PuntoPagosRails::Payable`. Este módulo extiende a nuestro modelo con todos los métodos, atributos, etc. relacionados con el pago que detallaré luego.

3. En base a un template, crea el `TransactionsController` encargado de manejar los pagos de los tickets. Este controller, tiene las acciones (y por tanto las url) requeridas por [PuntoPagos](https://www.puntopagos.com/).
> Cualquier modificación que se desee realizar al flujo normal (y más básico) de pago se deberá efectuar en este controlador.

4. Agrega las url de las que hablé en el paso anterior, al `routes.rb`

5. Copia la vista de "pago exitoso" en: `app/views/transactions/success.html.erb`. Esta es la vista donde nos redirigirá PuntoPagos cuando una transacción se complete sin errores. La idea es modificar el estilo de esta vista para que se adapte al de nuestra aplicación.

6. Copia la vista de "pago no exitoso" en: `app/views/transactions/error.html.erb`. Esta es la vista donde nos redirigirá PuntoPagos cuando falle una transacción.

> Por defecto, se genera un flujo para trabajar sin SSL. Si se desea activar el modo SSL, se debe pasar la opción `--ssl` al generador.

## Cómo realizar un pago?

Luego de instalar la gema y crear un flujo de pago, en alguna vista de nuestra aplicación y siguiendo con el modelo `Ticket` como ejemplo, deberemos tener el siguiente código:

```
<%= form_for(:ticket, url: transaction_create_path) do |f| %>
  Monto: <%= f.number_field(:amount) %><br />
  <%= f.submit "Pagar!" %>
<% end %>
```

El hacer click en "Pagar!" desatará el siguiente flujo:

1. Se hace un `POST your_app/transactions/create` con el `amount` del ticket. Esto crea una instancia de `Ticket` relacionada con una de `Transaction`. Si todo sale bien, se redirige a `puntopagos.com`. De lo contrario, a una vista de error.
2. Suponiendo que el paso anterior fué exitoso y ya en "terreno de puntopagos", el usuario realiza el pago. Independientemente de resultado de la transacción, puntopagos:
 - **Con SSL**, hace un `POST your_app/transactions/notification` con información sobre la transacción realizada.
 - **Sin SSL**, hace un `GET your_app/transactions/notification:token` con el token de la transacción realizada.
3. Dentro de la acción `notification` de nuestro `TransactionsController`, se analizan los datos enviados por puntopagos, se actualiza la información de la transacción (se completa o rechaza) y se contesta:
 - **Con SSL**, con un json de éxito o error.
 - **Sin SSL**, un `200 OK`.
4. Dependiendo del resultado del paso anterior, puntopagos nos redirigirá a `GET your_app/transactions/success` o `GET your_app/transactions/error`

Eso es todo!

## Funcionalidad en el modelo

Suponiendo que mi recurso pagable es: `Ticket` y tengo una instancia de este modelo llamada `@ticket` puedo:

```ruby
@ticket.transactions #para ver los intentos de pago (transacciones) relacionados al recurso.
@ticket.paid? #para saber si el recurso se pagó exitosamente.
```

Un ticket puede tener varias transacciones o intentos de pago, ya que un pago puede no ser exitoso la primera vez por diversos motivos como podría ser, por ejemplo, falta de fondos en la cuenta de quien paga. Por esto, es que las transacciones tienen alguno de los siguientes estados:

- `pending` estado inicial de una transacción.
- `completed` una transacción estará en este estado cuando el pago sea realizado con éxito.
- `rejected` una transacción tendrá este estado cuando el pago falle.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thank you [contributors](https://github.com/platanus/punto_pagos_rails/graphs/contributors)!

<img src="http://platan.us/gravatar_with_text.png" alt="Platanus" width="250"/>

punto_pagos_rails is maintained by [platanus](http://platan.us).

## License

PuntoPagosRails is © 2016 platanus, spa. It is free software and may be redistributed under the terms specified in the LICENSE file.
