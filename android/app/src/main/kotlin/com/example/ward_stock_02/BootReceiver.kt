package com.example.ward_stock_02

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
      Log.d("BootReceiver", "Device booted")
      try {
        val launchIntent = Intent(context, MainActivity::class.java)
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(launchIntent)
        Log.d("BootReceiver", "App launched successfully")
      } catch (e: Exception) {
        Log.e("BootReceiver", "Failed to launch app: ${e.message}")
      }
    }
  }
}
