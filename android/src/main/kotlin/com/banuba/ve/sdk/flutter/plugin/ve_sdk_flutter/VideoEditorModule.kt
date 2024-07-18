package com.banuba.ve.sdk.flutter.plugin.ve_sdk_flutter

import android.app.Application
import android.util.Size
import com.banuba.sdk.arcloud.data.source.ArEffectsRepositoryProvider
import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import com.banuba.sdk.cameraui.data.CameraConfig
import com.banuba.sdk.cameraui.data.CameraRecordingModesProvider
import com.banuba.sdk.cameraui.data.EditorPipLayoutSettings
import com.banuba.sdk.cameraui.data.PipLayoutProvider
import com.banuba.sdk.cameraui.ui.RecordMode
import com.banuba.sdk.core.ui.ext.dimen
import com.banuba.sdk.effectplayer.adapter.BanubaEffectPlayerKoinModule
import com.banuba.sdk.export.di.VeExportKoinModule
import com.banuba.sdk.playback.PlayerScaleType
import com.banuba.sdk.playback.di.VePlaybackSdkKoinModule
import com.banuba.sdk.ve.data.EditorAspectSettings
import com.banuba.sdk.ve.data.aspect.AspectSettings
import com.banuba.sdk.ve.data.aspect.AspectsProvider
import com.banuba.sdk.ve.di.VeSdkKoinModule
import com.banuba.sdk.ve.flow.di.VeFlowKoinModule
import com.banuba.sdk.veui.data.EditorConfig
import com.banuba.sdk.veui.di.VeUiSdkKoinModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import org.koin.core.qualifier.named
import org.koin.dsl.module

class VideoEditorModule {

    fun initialize(application: Application) {
        startKoin {
            androidContext(application)
            allowOverride(true)

            modules(
                VeSdkKoinModule().module,
                VeExportKoinModule().module,
                VePlaybackSdkKoinModule().module,

                // IMPORTANT! ArCloudKoinModule should be set before TokenStorageKoinModule to get effects from the cloud
                ArCloudKoinModule().module,

                VeUiSdkKoinModule().module,
                VeFlowKoinModule().module,
                BanubaEffectPlayerKoinModule().module,

                SampleIntegrationVeKoinModule().module,
            )
        }
    }
}

/**
 * All dependencies mentioned in this module will override default
 * implementations provided in VE UI SDK.
 * Some dependencies has no default implementations. It means that
 * these classes fully depends on your requirements
 */
private class SampleIntegrationVeKoinModule {
    private val minVideoDuration: Long = 20 * 1000
    private val maxVideoDuration: Long = 180 * 1000
    private val supportedDurations = listOf(minVideoDuration, 60_000, 120_000, maxVideoDuration)
    val module = module {
        single<ArEffectsRepositoryProvider>(createdAtStart = true) {
            ArEffectsRepositoryProvider(
                arEffectsRepository = get(named("backendArEffectsRepository")),
                ioDispatcher = get(named("ioDispatcher"))
            )
        }
        single<CameraConfig> {
            CameraConfig(
                supportsGallery = false,
                supportsExternalMusic = false,
                takePhotoOnTap = false,
                supportsMuteMic = false,
                videoDurations = supportedDurations,
                minRecordedTotalVideoDurationMs = minVideoDuration,
                maxRecordedTotalVideoDurationMs = maxVideoDuration,
                isStartFrontFacingFirst = true,

                isSaveLastCameraFacing = false,
            )
        }

        single<EditorConfig> {
            EditorConfig(
                supportsGalleryOnCover = false,
                supportsGalleryOnTrimmer = false,
                minTotalVideoDurationMs = minVideoDuration,
                maxTotalVideoDurationMs = maxVideoDuration,
            )
        }
        factory<PlayerScaleType>(named("editorVideoScaleType")) {
            PlayerScaleType.FIT_SCREEN_HEIGHT
        }
        single<AspectsProvider> {
            object : AspectsProvider{
                override var availableAspects: List<AspectSettings> = listOf()
                override fun provide(): AspectsProvider.AspectsData {
                    return AspectsProvider.AspectsData(
                        allAspects = availableAspects,
                        default = EditorAspectSettings.Original()
                    )
                }
            }
        }
        single<CameraRecordingModesProvider> {
            object : CameraRecordingModesProvider {
                override var availableModes: Set<RecordMode> = setOf(RecordMode.Video)
            }
        }
        single<PipLayoutProvider> {
            object : PipLayoutProvider {
                override fun provide(
                    insetsOffset: Int,
                    screenSize: Size
                ): List<EditorPipLayoutSettings> {
                    val context = androidContext()
                    return listOf(
                        EditorPipLayoutSettings.LeftRight(),
                        EditorPipLayoutSettings.Floating(
                            context = context,
                            physicalScreenSize = screenSize,
                            topOffsetPx = context.dimen(R.dimen.pip_floating_top_offset) + insetsOffset
                        ),
                        EditorPipLayoutSettings.TopBottom(),
                        EditorPipLayoutSettings.React(
                            context = context,
                            physicalScreenSize = screenSize,
                            topOffsetPx = context.dimen(R.dimen.pip_react_top_offset) + insetsOffset
                        ),
                    )

                }
            }
        }
    }
}
