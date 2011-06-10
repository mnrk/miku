# miku

A tiny web dev DSL

## Example

    {-# LANGUAGE OverloadedStrings #-}
    
    import Network.Miku
    import Hack2.Handler.HappstackServer
    
    main = run . miku $ get "/" (text "miku power")


## Installation

    cabal update
    cabal install miku
    cabal install hack2-handler-happstack
    
    -- copy and paste the above example to myapp.hs
    
    runghc myapp.hs

check: <http://localhost:3000>

## Quick reference

<https://github.com/nfjinjing/miku/blob/master/src/Test/Test.hs>


## Routes

### Verbs

    -- use - instead of $ for clarity
    import Air.Light ((-))
    import Prelude hiding ((-))
    
    import Network.Miku
    import Hack2.Handler.Happstack
    
    main = run . miku - do

      get "/" - do
        -- something for a get request

      post "/" - do
        -- for a post request
    
      put "/" - do
        -- put ..
    
      delete "/" - do
        -- ..

### Captures

    get "/say/:user/:message" - do
      text . show =<< captures

    -- /say/jinjing/hello will output
    -- [("user","jinjing"),("message","hello")]


## Static

    -- public serve, only allows `./src`
    public (Just ".") ["/src"]

## Mime types

    -- treat .hs extension as text/plain
    mime "hs" "text/plain"

## Filters

    -- before takes a function of type (Env -> IO Env)
    before - \e -> do
      putStrLn "before called"
      return e
    
    -- after takes that of type (Response -> IO Response)
    after return

## Hack2 integration

### Use hack middleware

    -- note both etag and lambda middleware are removed ... for somce ghc 7.0 compatability ><
    
    import Hack2.Contrib.Middleware.SimpleAccessLogger
    
    middleware - simple_access_logger Nothing

### Convert miku into a hack2 application

    -- in Network.Miku.Engine
    
    miku :: Unit -> Application


## Hints

* It's recommended to use your own html combinator / template engine. Try DIY with, e.g. [moe](http://github.com/nfjinjing/moe).
* [Example view using custom html combinator (moe in this case)](http://github.com/nfjinjing/miku/blob/master/src/Test/Moe.hs)
* When inspecting the request, use `ask` defined in `ReaderT` monad to get the `Hack2.Environment`, then use helper method defined in `Hack2.Contrib.Request` to query it.
* `Response` is in `StateT`, `html` and `text` are simply helper methods that update the state, i.e. setting the response body, content-type, etc.
* You do need to understand monad transformers to reach the full power of `miku`.
* For mac users, use `GHC 6.12.1` if you have trouble running the server.
    
## Reference

* miku is inspired by [Rack](http://rack.rubyforge.org), [Rails](http://rubyonrails.org), [Ramaze](http://ramaze.net), [Happstack](http://happstack.com/) and [Sinatra](http://www.sinatrarb.com/).


<br/>

<p>
<a href="http://en.wikipedia.org/wiki/Shinryaku!_Ika_Musume"><img src="https://github.com/nfjinjing/miku/raw/master/ita.jpg"/></a>
</p>