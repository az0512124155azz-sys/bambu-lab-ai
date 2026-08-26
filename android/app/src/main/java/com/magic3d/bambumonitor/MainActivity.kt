package com.magic3d.bambumonitor

import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

/**
 * Thin client: points at the backend's FastAPI server (run on your PC /
 * home server via install_windows.bat, or any always-on machine on your
 * LAN). Set SERVER_URL below to that machine's address, e.g.
 * "http://192.168.1.20:8000".
 *
 * This gets you a working phone app fast. Swap this WebView shell for a
 * native Compose UI later if you want push notifications to arrive via
 * FCM instead of ntfy/Telegram/Pushover.
 */
class MainActivity : AppCompatActivity() {

    companion object {
        const val SERVER_URL = "http://192.168.1.20:8000"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val webView = WebView(this)
        webView.settings.javaScriptEnabled = true
        webView.webViewClient = WebViewClient()
        setContentView(webView)
        webView.loadUrl(SERVER_URL)
    }
}
