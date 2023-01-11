module Config where

import IHP.Prelude
import IHP.Environment
import IHP.FrameworkConfig

config :: ConfigBuilder
config = do
    environment <- envOrDefault "IHP_ENV" Development
    option environment
    option (AppHostname "localhost")