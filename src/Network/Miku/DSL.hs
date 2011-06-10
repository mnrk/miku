module Network.Miku.DSL where

import Control.Monad.Reader
import Control.Monad.State
import Hack2
import Hack2.Contrib.Middleware.Censor
import Hack2.Contrib.Middleware.Config
import Hack2.Contrib.Middleware.IOConfig
import Hack2.Contrib.Middleware.Static
import Hack2.Contrib.Response
import Hack2.Contrib.Constants
import Air
import Network.Miku.Config
import Network.Miku.Engine
import Network.Miku.Type
import Network.Miku.Utils
import Prelude hiding ((.), (>), (^), (-))
import qualified Control.Monad.State as State
import Data.ByteString.Lazy.Char8 (ByteString)

app :: Application -> AppUnit
app f = ask >>= (f > io) >>= State.put


router :: Router -> Unit
router = set_router > update

get, put, post, delete :: ByteString -> AppUnit -> Unit
get    = add_route GET
put    = add_route PUT
post   = add_route POST
delete = add_route DELETE


middleware :: Middleware -> Unit
middleware = add_middleware > update

before :: (Env -> IO Env) -> Unit
before = ioconfig > middleware

after :: (Response -> IO Response) -> Unit
after = censor > middleware

mime :: ByteString -> ByteString -> Unit
mime k v = add_mime k v .update

public :: Maybe ByteString -> [ByteString] -> Unit
public r xs = middleware - static r xs

io :: (MonadIO m) => IO a -> m a
io = liftIO

text :: ByteString -> AppUnit
text x = do
  update - set_content_type _TextPlain
  update - set_body x

html :: ByteString -> AppUnit
html x = do
  update - set_content_type _TextHtml
  update - set_body x


captures :: AppUnitT [(ByteString, ByteString)]
captures = ask ^ namespace miku_captures