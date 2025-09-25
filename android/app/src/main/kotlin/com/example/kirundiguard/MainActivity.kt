package com.example.kirundiguard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val CHANNEL = "kirundiguard/ai"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "generateExplanation" -> {
                    val text = call.argument<String>("text")
                    val explanation = generateExplanation(text ?: "")
                    result.success(explanation)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun generateExplanation(text: String): Map<String, Any> {
        // Stub implementation - replace with actual AI Edge SDK call
        return mapOf(
            "summary_rn" to "Ibi bisobanuro by'icyemezo cy'ubwiyunge bw'abaturage",
            "sections_rn" to listOf(
                mapOf(
                    "title" to "Ibisobanuro",
                    "text" to "Iki cyemezo gishingiye ku mategeko y'igihugu"
                ),
                mapOf(
                    "title" to "Inshingano",
                    "text" to "Abaturage bagomba kubahiriza amategeko yose"
                )
            ),
            "checklist_rn" to listOf(
                "Soma cyangwa umve inyandiko yose",
                "Baza ibibazo niba hari icyo utumva",
                "Kubana n'abunganira mu mategeko niba bikenewe"
            ),
            "disclaimer_rn" to "Ibi si inama z'abunganira mu mategeko."
        )
    }
}
