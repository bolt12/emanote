{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE TemplateHaskell #-}

module Emanote.Model.StaticFile where

import Commonmark.Extensions.WikiLink qualified as WL
import Data.Aeson qualified as Aeson
import Data.IxSet.Typed (Indexable (..), IxSet, ixFun, ixList)
import Data.Time (UTCTime)
import Emanote.Route qualified as R
import Optics.TH (makeLenses)
import Relude
import System.FilePath (takeExtension)

data StaticFile = StaticFile
  { _staticFileRoute :: R.R 'R.AnyExt
  , _staticFilePath :: FilePath
  , _staticFileTime :: UTCTime
  -- ^ Indicates that this file was updated no latter than the given time.
  , _staticFileInfo :: Maybe StaticFileInfo
  -- ^ This file might have its content read
  }
  deriving stock (Eq, Ord, Show, Generic)
  deriving anyclass (Aeson.ToJSON)

type StaticFileIxs = '[R.R 'R.AnyExt, WL.WikiLink]

type IxStaticFile = IxSet StaticFileIxs StaticFile

instance Indexable StaticFileIxs StaticFile where
  indices =
    ixList
      (ixFun $ one . _staticFileRoute)
      (ixFun $ toList . staticFileSelfRefs)

staticFileSelfRefs :: StaticFile -> NonEmpty WL.WikiLink
staticFileSelfRefs =
  fmap snd
    . WL.allowedWikiLinks
    . R.unRoute
    . _staticFileRoute

data StaticFileInfo where
  StaticFileInfoImage :: StaticFileInfo
  StaticFileInfoAudio :: StaticFileInfo
  StaticFileInfoVideo :: StaticFileInfo
  StaticFileInfoPDF :: StaticFileInfo
  StaticFileInfoCode :: Text -> StaticFileInfo
  deriving stock (Eq, Show, Ord, Generic)
  deriving anyclass (Aeson.ToJSON)

staticFileInfoToName :: IsString s => StaticFileInfo -> s
staticFileInfoToName StaticFileInfoImage = "image"
staticFileInfoToName StaticFileInfoAudio = "audio"
staticFileInfoToName StaticFileInfoVideo = "video"
staticFileInfoToName StaticFileInfoPDF = "pdf"
staticFileInfoToName (StaticFileInfoCode _) = "code"

readStaticFileInfo ::
  Monad m =>
  FilePath ->
  (FilePath -> m Text) ->
  m (Maybe StaticFileInfo)
readStaticFileInfo fp readFilePath = do
  let extension = toText (takeExtension fp)
  if
      | extension `elem` imageExts -> staticFileImage
      | extension `elem` videoExts -> staticFileVideo
      | extension `elem` audioExts -> staticFileAudio
      | extension == "pdf" -> staticFilePDF
      | extension `elem` codeExts -> staticFileCode
      | otherwise -> return Nothing
  where
    imageExts = [".jpg", ".jpeg", ".png", ".svg", ".gif", ".bmp", ".webp"]
    videoExts = [".mp4", ".webm", ".ogv"]
    audioExts = [".aac", ".caf", ".flac", ".mp3", ".ogg", ".wav", ".wave"]
    codeExts =
      [ ".hs"
      , ".sh"
      , ".py"
      , ".js"
      , ".java"
      , ".c"
      , ".cpp"
      , ".cs"
      , ".rb"
      , ".go"
      , ".swift"
      , ".kt"
      , ".rs"
      , ".ts"
      , ".php"
      ]
    staticFileImage = return $ Just StaticFileInfoImage
    staticFileVideo = return $ Just StaticFileInfoImage
    staticFileAudio = return $ Just StaticFileInfoAudio
    staticFilePDF = return $ Just StaticFileInfoPDF
    staticFileCode =
      readFilePath fp
        <&> Just . StaticFileInfoCode

makeLenses ''StaticFile
