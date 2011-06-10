import Network.Miku
import Hack2.Handler.Happstack

main = run . miku $ get "/" (text "miku power")