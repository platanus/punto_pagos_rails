# PuntoPagosRails [![Gem Version](https://badge.fury.io/rb/punto_pagos_rails.svg)](http://badge.fury.io/rb/punto_pagos_rails) [![Build Status](https://travis-ci.org/platanus/punto_pagos_rails.svg?branch=master)](https://travis-ci.org/platanus/punto_pagos_rails)

Esta gema es un engine construído sobre [puntopagos-ruby](https://github.com/acidlabs/puntopagos-ruby) con la intención de integrar a una Rails app el flujo de pago básico o más común que podemos encontrar normalmente en una aplicación.

## Instalación

Agrega a tu `Gemfile`

```ruby
gem 'punto_pagos_rails'
```

Luego, se debe correr el generador

```bash
$ rails generate punto_pagos_rails:install tu_entidad_pagable
```

**tu_entidad_pagable** es el nombre del modelo de `ActiveRecord` que hace referencia a la entidad o recurso "pagable" de tu aplicación. Por ej: ticket, appointment, product, etc.

El instalador hace lo siguiente:

1. Revisa si el modelo (la entidad pagable) existe. Si no existe, lo crea y, en cualquier caso, agrega el atributo `amount`. Amount es el atributo donde configuraremos el valor de la entidad pagable. Por ej: si hicimos una aplicación para vender tickets para festivales y el valor de un ticket es $100, ese 100 deberá almacenarse en `amount`.

2. Incluye en este modelo el módulo: `PuntoPagosRails::ResourceExtension`. Este módulo extiende a nuestro modelo con todos los métodos, atributos, etc. relacionados con el pago que detallaré luego.

3. Copia la migración que crea la tabla `punto_pagos_rails_transactions`. En esta tabla se almacenarán todos los pagos (o intentos de pago) que se realizarán sobre nuestro recurso pagable. Es decir, **un recurso puede tener 0 o muchas transacciones**. El caso normal es que tenga una, pero pueden exisitir más si falla el pago por ej. Estas transacciones tendrán alguno de los siguientes estados:
    - `pending` estado inicial de una transacción.
    - `completed` una transacción estará en este estado cuando el pago sea realizado con éxito.
    - `rejected` una transacción tendrá este estado cuando el pago falle.

4. Crea un initializer para nuestra gema en: `/your_app/config/initializers/punto_pagos_rails.rb` con la configuración básica para funcionar.

5. Crea `/your_app/config/puntopagos.yml`. Este archivo debe modificarse con las credenciales para la comunicación con PuntoPago.

6. Copia la vista de "pago exitoso" en: `app/views/punto_pagos_rails/transactions/success.html.erb`. Esta es la vista donde nos redirigirá PuntoPagos cuando una trasacción se complete sin errores. La idea es modificar el estilo de esta view para que se adapte al de nuestra aplicación. Aquí podremos acceder a la variable: `@resource` que contiene la instancia de lo que acabamos de pagar. Por ej: si nuestro modelo pagable es `Ticket`, `@resource` contendrá una instancia de `Ticket`.

7. Copia la vista de "pago no exitoso" en: `app/views/punto_pagos_rails/transactions/error.html.erb`. Esta es la vista donde nos redirigirá PuntoPagos cuando falle una transacción. Del mismo modo que con la vista de `success.html`, se podrá acceder al `@resource` para dar más detalle al usuario de lo que está pasando.

Por útlimo:

```bash
$ rake db:migrate
```

## Cómo realizar un pago?

Luego de instalar la gema, en algún lado de nuestra aplicación, deberemos tener el siguiente código:

En un controller...

```ruby
def some_action
  @ticket = Ticket.create! amount: 100
end
```

Obviamente `@ticket` hace referencia a una instancia de nuestro modelo pagable. Esto variará dependiendo de nuestra aplicación.

En la vista de `some_action`...

```
<%= form_tag(punto_pagos_rails.transaction_create_path({resource_id: @ticket.id})) do %>
  <%= submit_tag "Pagar!" %>
<% end %>
```

Eso es todo!

## Flujo

1. Usuario hace clic en el botón pagar.
2. Eso hace una redirección a PuntoPagos.
3. El usuario relaliza el pago.
4. PuntoPagos redirige a vista de éxito (en caso de transacción exitosa) o vista de error si sucede lo contrario.

## Funcionalidad en el modelo

Suponiendo que mi recurso pagable es: `Ticket` y tengo una instancia de este modelo llamada `@ticket` puedo:

```ruby
@ticket.transactions #para ver los intentos de pago (transacciones) relacionados al recurso.
@ticket.paid? #para saber si el recurso se pagó exitosamente.
```

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

Guides is © 2014 platanus, spa. It is free software and may be redistributed under the terms specified in the LICENSE file.

