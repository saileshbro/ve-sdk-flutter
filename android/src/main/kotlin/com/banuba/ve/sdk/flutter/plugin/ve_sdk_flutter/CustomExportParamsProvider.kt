package com.banuba.ve.sdk.flutter.plugin.ve_sdk_flutter

import android.net.Uri
import androidx.core.net.toFile
import com.banuba.sdk.core.VideoResolution
import com.banuba.sdk.core.media.MediaFileNameHelper
import com.banuba.sdk.export.data.ExportParams
import com.banuba.sdk.export.data.ExportParamsProvider
import com.banuba.sdk.ve.domain.VideoRangeList
import com.banuba.sdk.ve.effects.Effects
import com.banuba.sdk.ve.effects.music.MusicEffect
import java.io.File

class CustomExportParamsProvider(
    private val exportDir: Uri,
    private val mediaFileNameHelper: MediaFileNameHelper,
) : ExportParamsProvider {

    override fun provideExportParams(
        effects: Effects,
        videoRangeList: VideoRangeList,
        musicEffects: List<MusicEffect>,
        videoVolume: Float
    ): List<ExportParams> = listOf(
        ExportParams.Builder(VideoResolution.Exact.HD)
            .effects(effects)
            .fileName(mediaFileNameHelper.generateExportName())
            .debugEnabled(true)
            .videoRangeList(videoRangeList)
            .destDir(exportDir.toFile().apply(File::mkdirs))
            .musicEffects(musicEffects)
            .volumeVideo(videoVolume)
            .useHevcIfPossible(false)
            .build()
    )
}