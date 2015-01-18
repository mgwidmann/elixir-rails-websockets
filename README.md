# Elixir-Rails Websockets

This project leverages the [Phoenix](https://github.com/phoenixframework/phoenix) web framework, written in [Elixir](http://www.elixir-lang.org/), which has a superb web socket system. Phoenix can handle a large load of web socket traffic due to the Erlang VM's actor model of concurrency.

This project allows you to extend any existing `GET` endpoint you currently have with web sockets by polling your rails (or any other) server.

## Installation

Ensure [Elixir is installed](http://elixir-lang.org/install.html).

To start the Phoenix application:

1. Install dependencies with `mix deps.get`
2. Start Phoenix endpoint with `mix phoenix.server`

The interface is located in http://localhost:4000/interface.

## Example Usage

Open the browser to the interface. Fill out the timeout and URL field (or leave them to their default) and click "Connect".

For example, the defaults have a 1 second timeout and connects to `http://www.google.com/`. JSON data will always be returned, but if the content is HTML, the data gets returned in an `html` field like so:

```
{
  "html": "<html><body>Example</body></html>"
}
```

Otherwise, JSON data will be returned exactly as retrieved. As shown with the default setup, content comes back every second. But that is only because the content is different each time google is fetched. If the content was identical to what was fetch previously, no data would be pushed back to the client. If you change the URL to `http://www.yahoo.com` where the content doesn't changed you will not see any traffic on the socket (if you use developer tools to inspect).
